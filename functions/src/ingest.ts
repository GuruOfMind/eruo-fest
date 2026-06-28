import * as admin from "firebase-admin";

import { bandsintownAdapter } from "./adapters/bandsintown";
import { ticketmasterAdapter } from "./adapters/ticketmaster";
import { AffiliateConfig, defaultAffiliateConfig } from "./affiliate";
import { dedupeBatch, mergeEvents, normalizeEvent } from "./normalize";
import { ArtistResolver, NormalizedEvent, RawEvent } from "./types";

/**
 * Fetchers are injected so ingest can be exercised against fixtures/emulator
 * without live API keys. Each returns the raw API payload for an adapter to
 * parse.
 */
export interface IngestFetchers {
  // Per-artist keyword search — the right model for a curated catalog: a
  // city-wide scan never intersects niche MENA artists, but searching each
  // artist by name surfaces their actual tour dates.
  ticketmasterByKeyword(keyword: string): Promise<unknown>;
  // Optional: only wired when BANDSINTOWN_APP_ID is set. Disabled for now.
  bandsintownByArtist?(artistName: string): Promise<unknown>;
}

/**
 * Country codes we keep events for — EuroFest targets expats in Europe, so we
 * drop a followed artist's non-European dates (e.g. US/Canada shows).
 * Overridable via `EUROFEST_COUNTRIES` (comma-separated ISO-3166 alpha-2).
 */
export function europeanCountries(
  env: NodeJS.ProcessEnv = process.env,
): Set<string> {
  const fromEnv = (env.EUROFEST_COUNTRIES ?? "")
    .split(",")
    .map((c) => c.trim().toUpperCase())
    .filter(Boolean);
  return new Set(
    fromEnv.length
      ? fromEnv
      : [
          "DE", "FR", "GB", "NL", "BE", "AT", "CH", "SE", "DK", "NO",
          "ES", "IT", "PT", "IE", "FI", "PL", "CZ", "HU", "GR", "LU",
        ],
  );
}

/**
 * Builds a name→catalog-id resolver from the `artists` collection, indexing
 * the Latin name, Arabic name, and aliases (all lower-cased).
 */
export function buildResolver(
  artists: { id: string; name?: string; nameAr?: string; aliases?: string[] }[],
): ArtistResolver {
  const index = new Map<string, string>();
  for (const a of artists) {
    for (const key of [a.name, a.nameAr, ...(a.aliases ?? [])]) {
      if (key) index.set(key.trim().toLowerCase(), a.id);
    }
  }
  return (name: string) => index.get(name.trim().toLowerCase()) ?? null;
}

/**
 * Pure pipeline core: parse every source payload, normalize against the
 * resolver, then dedupe-merge the batch. Unit-testable without Firestore.
 */
export function buildEvents(
  payloads: { adapterSource: string; payload: unknown }[],
  resolver: ArtistResolver,
  affiliateConfig: AffiliateConfig,
  now?: Date,
  allowedCountries?: Set<string>,
): NormalizedEvent[] {
  const adapters = [ticketmasterAdapter, bandsintownAdapter];
  const raw: RawEvent[] = [];
  for (const { adapterSource, payload } of payloads) {
    const adapter = adapters.find((a) => a.source === adapterSource);
    if (adapter) raw.push(...adapter.parse(payload));
  }
  const normalized = raw
    .map((r) => normalizeEvent(r, resolver, affiliateConfig, now))
    .filter((e): e is NormalizedEvent => e !== null)
    .filter(
      (e) =>
        !allowedCountries || allowedCountries.has((e.country ?? "").toUpperCase()),
    );
  return dedupeBatch(normalized);
}

/**
 * Full ingest run: load the catalog, pull each tracked artist/city from the
 * sources, normalize+dedupe, and upsert into `events` keyed by `dedupeKey`
 * (merging with any existing doc). Requires Firestore credentials/emulator.
 */
export async function runIngest(
  db: admin.firestore.Firestore,
  fetchers: IngestFetchers,
  affiliateConfig: AffiliateConfig = defaultAffiliateConfig(),
): Promise<{ upserted: number; created: NormalizedEvent[] }> {
  const artistsSnap = await db.collection("artists").get();
  const artists = artistsSnap.docs.map((d) => ({ id: d.id, ...d.data() }));
  const resolver = buildResolver(artists as never);

  // Search each catalog artist by name across the sources. A single artist's
  // source failure is logged and skipped — one error must not abort the run.
  const payloads: { adapterSource: string; payload: unknown }[] = [];
  for (const a of artists as { name?: string }[]) {
    if (!a.name) continue;
    try {
      payloads.push({
        adapterSource: "ticketmaster",
        payload: await fetchers.ticketmasterByKeyword(a.name),
      });
    } catch (e) {
      console.warn(`ticketmaster fetch failed for ${a.name}:`, (e as Error).message);
    }
    // Bandsintown is optional (disabled unless BANDSINTOWN_APP_ID is set).
    if (fetchers.bandsintownByArtist) {
      try {
        payloads.push({
          adapterSource: "bandsintown",
          payload: await fetchers.bandsintownByArtist(a.name),
        });
      } catch (e) {
        console.warn(`bandsintown fetch failed for ${a.name}:`, (e as Error).message);
      }
    }
  }

  const events = buildEvents(
    payloads,
    resolver,
    affiliateConfig,
    undefined,
    europeanCountries(),
  );

  let upserted = 0;
  const created: NormalizedEvent[] = [];
  for (const event of events) {
    const ref = db.collection("events").doc(event.dedupeKey);
    const isNew = await db.runTransaction(async (tx) => {
      const existing = await tx.get(ref);
      const data = existing.exists
        ? mergeEvents(existing.data() as NormalizedEvent, event)
        : event;
      tx.set(ref, data, { merge: true });
      return !existing.exists;
    });
    upserted++;
    // Newly-announced events drive notifications (the core value prop).
    if (isNew) created.push(event);
  }
  return { upserted, created };
}
