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
  ticketmasterByCity(city: string, country: string): Promise<unknown>;
  bandsintownByArtist(artistName: string): Promise<unknown>;
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
): NormalizedEvent[] {
  const adapters = [ticketmasterAdapter, bandsintownAdapter];
  const raw: RawEvent[] = [];
  for (const { adapterSource, payload } of payloads) {
    const adapter = adapters.find((a) => a.source === adapterSource);
    if (adapter) raw.push(...adapter.parse(payload));
  }
  const normalized = raw
    .map((r) => normalizeEvent(r, resolver, affiliateConfig, now))
    .filter((e): e is NormalizedEvent => e !== null);
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

  // Cities to pull from city-based sources (Ticketmaster). Derived from the
  // distinct home cities users have chosen.
  const usersSnap = await db.collection("users").get();
  const cities = new Set<string>();
  usersSnap.forEach((u) => {
    const c = u.get("homeCity");
    if (typeof c === "string" && c) cities.add(c);
  });

  const payloads: { adapterSource: string; payload: unknown }[] = [];
  for (const city of cities) {
    payloads.push({
      adapterSource: "ticketmaster",
      payload: await fetchers.ticketmasterByCity(city, ""),
    });
  }
  for (const a of artists as { name?: string }[]) {
    if (!a.name) continue;
    payloads.push({
      adapterSource: "bandsintown",
      payload: await fetchers.bandsintownByArtist(a.name),
    });
  }

  const events = buildEvents(payloads, resolver, affiliateConfig);

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
