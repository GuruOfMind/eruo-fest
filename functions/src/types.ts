/** Lifecycle state mirrored from a source, matching the Flutter `EventStatus`. */
export type EventStatus = "announced" | "onsale" | "soldout" | "cancelled";

/**
 * Source-agnostic event as produced by an adapter, before normalization.
 * Artist/venue are still by name here; resolution to catalog ids happens in
 * `normalize`.
 */
export interface RawEvent {
  source: string; // e.g. "ticketmaster", "bandsintown"
  sourceEventId: string;
  artistNames: string[];
  venueName: string;
  city: string;
  country: string; // ISO-3166 alpha-2
  startsAt: string; // ISO-8601
  status: EventStatus;
  ticketUrl?: string; // raw URL, before affiliate wrapping
  priceFrom?: number;
  currency?: string;
  lat?: number;
  lng?: number;
}

/** Canonical event written to Firestore `events`. Mirrors the Flutter model. */
export interface NormalizedEvent {
  artistIds: string[];
  venueId: string;
  venueName: string;
  city: string;
  country: string;
  startsAt: string;
  status: EventStatus;
  ticketUrl?: string; // affiliate-wrapped
  priceFrom?: number;
  currency?: string;
  sources: string[];
  dedupeKey: string;
  announcedAt: string;
}

/**
 * A pull source. `fetch` is the impure HTTP call; `parse` is the pure mapper
 * from a raw API payload to [RawEvent]s. Keeping `parse` separate lets us unit
 * test adapters against recorded fixtures without network or credentials.
 */
export interface SourceAdapter {
  readonly source: string;
  parse(payload: unknown): RawEvent[];
}

/** Resolves a performer name (any script) to a catalog artist id, or null. */
export type ArtistResolver = (name: string) => string | null;
