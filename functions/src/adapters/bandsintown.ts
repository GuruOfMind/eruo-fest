import { EventStatus, RawEvent, SourceAdapter } from "../types";

/**
 * Adapter for the Bandsintown API (`/artists/{name}/events`). `parse` expects
 * the raw JSON array of events returned for a single artist. Ticket status
 * comes from the "Tickets" offer; absent offers mean the show is merely
 * announced.
 */
export const bandsintownAdapter: SourceAdapter = {
  source: "bandsintown",

  parse(payload: unknown): RawEvent[] {
    const events = Array.isArray(payload) ? (payload as BitEvent[]) : [];
    return events.map((e): RawEvent => {
      const ticketOffer = (e.offers ?? []).find((o) => o.type === "Tickets");
      return {
        source: "bandsintown",
        sourceEventId: String(e.id),
        artistNames: e.lineup ?? [],
        venueName: e.venue?.name ?? "",
        city: e.venue?.city ?? "",
        country: e.venue?.country ?? "",
        startsAt: e.datetime ?? "",
        status: mapStatus(ticketOffer?.status),
        ticketUrl: ticketOffer?.url ?? e.url,
        lat: toNum(e.venue?.latitude),
        lng: toNum(e.venue?.longitude),
      };
    });
  },
};

function mapStatus(offerStatus: string | undefined): EventStatus {
  switch (offerStatus) {
    case "available":
      return "onsale";
    case "sold out":
      return "soldout";
    default:
      return "announced";
  }
}

function toNum(v: string | number | undefined): number | undefined {
  if (v === undefined) return undefined;
  const n = typeof v === "number" ? v : parseFloat(v);
  return Number.isFinite(n) ? n : undefined;
}

interface BitEvent {
  id: string | number;
  url?: string;
  datetime?: string;
  title?: string;
  lineup?: string[];
  venue?: {
    name?: string;
    city?: string;
    country?: string;
    latitude?: string | number;
    longitude?: string | number;
  };
  offers?: { type?: string; url?: string; status?: string }[];
}
