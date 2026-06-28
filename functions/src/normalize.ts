import { AffiliateConfig, wrapAffiliateUrl } from "./affiliate";
import { ArtistResolver, EventStatus, NormalizedEvent, RawEvent } from "./types";

/** URL/id-safe slug; collapses non-alphanumerics and trims. */
export function slugify(input: string): string {
  return input
    .toLowerCase()
    .normalize("NFKD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[^a-z0-9؀-ۿ]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

/** YYYY-MM-DD in UTC from an ISO string (day granularity for dedupe). */
function dayOf(iso: string): string {
  const d = new Date(iso);
  return Number.isNaN(d.getTime()) ? "" : d.toISOString().slice(0, 10);
}

/**
 * Stable key identifying "the same show" across sources: day + city + the set
 * of performing artists. Two raw events from Ticketmaster and Bandsintown for
 * the same concert collapse to one canonical event.
 */
export function computeDedupeKey(
  artistIds: string[],
  city: string,
  startsAt: string,
): string {
  const artistKey = [...artistIds].sort().join(",");
  return `${dayOf(startsAt)}|${slugify(city)}|${artistKey}`;
}

/** Resolves performer names to catalog ids, dropping unknowns and duplicates. */
function resolveArtists(names: string[], resolver: ArtistResolver): string[] {
  const ids = new Set<string>();
  for (const name of names) {
    const id = resolver(name);
    if (id) ids.add(id);
  }
  return [...ids];
}

/**
 * Maps a [RawEvent] to the canonical [NormalizedEvent], resolving artists,
 * computing the venue id + dedupe key, and applying affiliate tracking.
 * Returns null when no catalog artist could be resolved (we only store events
 * for artists in our catalog).
 */
export function normalizeEvent(
  raw: RawEvent,
  resolver: ArtistResolver,
  affiliateConfig: AffiliateConfig,
  now: Date = new Date(),
): NormalizedEvent | null {
  const artistIds = resolveArtists(raw.artistNames, resolver);
  if (artistIds.length === 0) return null;

  return {
    artistIds,
    venueId: slugify(`${raw.venueName}-${raw.city}`),
    venueName: raw.venueName,
    city: raw.city,
    country: raw.country,
    startsAt: raw.startsAt,
    status: raw.status,
    ticketUrl: wrapAffiliateUrl(raw.source, raw.ticketUrl, affiliateConfig),
    priceFrom: raw.priceFrom,
    currency: raw.currency,
    sources: [raw.source],
    dedupeKey: computeDedupeKey(artistIds, raw.city, raw.startsAt),
    announcedAt: now.toISOString(),
  };
}

// Status precedence when merging: a "harder" signal wins.
const STATUS_RANK: Record<EventStatus, number> = {
  announced: 0,
  onsale: 1,
  soldout: 2,
  cancelled: 3,
};

/**
 * Merges a newly-seen event into an existing canonical one (same dedupeKey):
 * unions sources & artists, keeps the strongest status, the earliest
 * announcedAt, and the first available ticket URL / price.
 */
export function mergeEvents(
  existing: NormalizedEvent,
  incoming: NormalizedEvent,
): NormalizedEvent {
  const status =
    STATUS_RANK[incoming.status] > STATUS_RANK[existing.status]
      ? incoming.status
      : existing.status;
  return {
    ...existing,
    status,
    artistIds: [...new Set([...existing.artistIds, ...incoming.artistIds])],
    sources: [...new Set([...existing.sources, ...incoming.sources])],
    ticketUrl: existing.ticketUrl ?? incoming.ticketUrl,
    priceFrom: existing.priceFrom ?? incoming.priceFrom,
    currency: existing.currency ?? incoming.currency,
    announcedAt:
      existing.announcedAt < incoming.announcedAt
        ? existing.announcedAt
        : incoming.announcedAt,
  };
}

/**
 * Collapses a batch of normalized events by dedupeKey, merging duplicates.
 */
export function dedupeBatch(events: NormalizedEvent[]): NormalizedEvent[] {
  const byKey = new Map<string, NormalizedEvent>();
  for (const e of events) {
    const prior = byKey.get(e.dedupeKey);
    byKey.set(e.dedupeKey, prior ? mergeEvents(prior, e) : e);
  }
  return [...byKey.values()];
}
