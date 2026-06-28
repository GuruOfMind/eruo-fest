import { EventStatus, RawEvent, SourceAdapter } from "../types";

/** Maps a Ticketmaster `dates.status.code` to our status. */
function mapStatus(code: string | undefined): EventStatus {
  switch (code) {
    case "cancelled":
      return "cancelled";
    case "onsale":
      return "onsale";
    case "offsale":
      return "soldout";
    default:
      return "announced";
  }
}

/**
 * Adapter for the Ticketmaster Discovery API (`/discovery/v2/events`).
 * `parse` expects the raw JSON response body. When the affiliate program is
 * enabled, `url` already carries tracking params; we still pass it through
 * `affiliate.ts` so any missing params are added consistently.
 */
export const ticketmasterAdapter: SourceAdapter = {
  source: "ticketmaster",

  parse(payload: unknown): RawEvent[] {
    const body = payload as TmResponse;
    const events = body?._embedded?.events ?? [];
    return events.map((e): RawEvent => {
      const venue = e._embedded?.venues?.[0];
      const price = e.priceRanges?.[0];
      return {
        source: "ticketmaster",
        sourceEventId: e.id,
        artistNames: (e._embedded?.attractions ?? [])
          .map((a) => a.name)
          .filter((n): n is string => Boolean(n)),
        venueName: venue?.name ?? "",
        city: venue?.city?.name ?? "",
        country: venue?.country?.countryCode ?? "",
        startsAt: e.dates?.start?.dateTime ?? "",
        status: mapStatus(e.dates?.status?.code),
        ticketUrl: e.url,
        priceFrom: price?.min,
        currency: price?.currency,
        lat: toNum(venue?.location?.latitude),
        lng: toNum(venue?.location?.longitude),
      };
    });
  },
};

function toNum(v: string | number | undefined): number | undefined {
  if (v === undefined) return undefined;
  const n = typeof v === "number" ? v : parseFloat(v);
  return Number.isFinite(n) ? n : undefined;
}

// Minimal shape of the Discovery API response we rely on.
interface TmResponse {
  _embedded?: { events?: TmEvent[] };
}
interface TmEvent {
  id: string;
  name?: string;
  url?: string;
  dates?: { start?: { dateTime?: string }; status?: { code?: string } };
  priceRanges?: { min?: number; max?: number; currency?: string }[];
  _embedded?: {
    venues?: {
      name?: string;
      city?: { name?: string };
      country?: { countryCode?: string };
      location?: { latitude?: string; longitude?: string };
    }[];
    attractions?: { name?: string }[];
  };
}
