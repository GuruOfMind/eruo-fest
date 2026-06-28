import { EventStatus, RawEvent, SourceAdapter } from "../types";

/**
 * Adapter for Eventim data produced by `eventim/fetch_eventim.py` (which uses
 * the `pyventim` public `product_groups` API). The Python side already maps to
 * this near-canonical shape; `parse` just validates and tags the source. We
 * keep the artist name as the Eventim **tour/group title** (e.g. "Amr Diab -
 * Live 2026") and let the fuzzy resolver match it to a catalog artist.
 */
export const eventimAdapter: SourceAdapter = {
  source: "eventim",

  parse(payload: unknown): RawEvent[] {
    const rows = Array.isArray(payload) ? (payload as EventimRow[]) : [];
    return rows
      .filter((r) => r && r.startsAt && (r.artistNames?.length ?? 0) > 0)
      .map((r) => ({
        source: "eventim",
        sourceEventId: String(r.sourceEventId ?? ""),
        artistNames: r.artistNames ?? [],
        venueName: r.venueName ?? "",
        city: r.city ?? "",
        country: (r.country ?? "").toUpperCase(),
        startsAt: r.startsAt,
        status: normalizeStatus(r.status),
        ticketUrl: r.ticketUrl,
        priceFrom: typeof r.priceFrom === "number" ? r.priceFrom : undefined,
        currency: r.currency,
        lat: typeof r.lat === "number" ? r.lat : undefined,
        lng: typeof r.lng === "number" ? r.lng : undefined,
      }));
  },
};

function normalizeStatus(s: string | undefined): EventStatus {
  switch ((s ?? "").toLowerCase()) {
    case "soldout":
    case "sold_out":
    case "booked":
      return "soldout";
    case "cancelled":
    case "canceled":
      return "cancelled";
    case "onsale":
    case "available":
      return "onsale";
    default:
      return "announced";
  }
}

interface EventimRow {
  sourceEventId?: string | number;
  artistNames?: string[];
  venueName?: string;
  city?: string;
  country?: string;
  startsAt: string;
  status?: string;
  ticketUrl?: string;
  priceFrom?: number;
  currency?: string;
  lat?: number;
  lng?: number;
}
