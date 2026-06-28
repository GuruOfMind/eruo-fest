import { describe, expect, it } from "vitest";

import { ticketmasterAdapter } from "../src/adapters/ticketmaster";
import { bandsintownAdapter } from "../src/adapters/bandsintown";
import { buildEvents } from "../src/ingest";
import {
  computeDedupeKey,
  dedupeBatch,
  mergeEvents,
  normalizeEvent,
  slugify,
} from "../src/normalize";
import { NormalizedEvent, RawEvent } from "../src/types";
import { fixture, testResolver } from "./helpers";

const noAffiliate = {};
const fixedNow = new Date("2026-06-28T00:00:00Z");

function rawCairokee(source: string, overrides: Partial<RawEvent> = {}): RawEvent {
  return {
    source,
    sourceEventId: `${source}-1`,
    artistNames: ["Cairokee"],
    venueName: "Columbiahalle",
    city: "Berlin",
    country: "DE",
    startsAt: "2026-09-12T19:00:00Z",
    status: "announced",
    ticketUrl: `https://${source}.example/e/1`,
    ...overrides,
  };
}

describe("slugify", () => {
  it("makes url-safe slugs", () => {
    expect(slugify("Columbiahalle, Berlin!")).toBe("columbiahalle-berlin");
  });
});

describe("computeDedupeKey", () => {
  it("is identical for the same artists/day/city regardless of source", () => {
    const a = computeDedupeKey(["cairokee"], "Berlin", "2026-09-12T19:00:00Z");
    const b = computeDedupeKey(["cairokee"], "Berlin", "2026-09-12T21:30:00+02:00");
    expect(a).toBe(b);
  });
});

describe("normalizeEvent", () => {
  it("resolves catalog artists and builds the canonical event", () => {
    const out = normalizeEvent(rawCairokee("ticketmaster"), testResolver, noAffiliate, fixedNow);
    expect(out).not.toBeNull();
    expect(out!.artistIds).toEqual(["cairokee"]);
    expect(out!.venueId).toBe("columbiahalle-berlin");
    expect(out!.sources).toEqual(["ticketmaster"]);
  });

  it("drops events with no catalog artist", () => {
    const raw = rawCairokee("ticketmaster", { artistNames: ["Unknown Band"] });
    expect(normalizeEvent(raw, testResolver, noAffiliate, fixedNow)).toBeNull();
  });
});

describe("mergeEvents", () => {
  it("keeps the strongest status and unions sources", () => {
    const tm = normalizeEvent(
      rawCairokee("ticketmaster", { status: "onsale" }),
      testResolver,
      noAffiliate,
      fixedNow,
    )!;
    const bit = normalizeEvent(
      rawCairokee("bandsintown", { status: "soldout" }),
      testResolver,
      noAffiliate,
      fixedNow,
    )!;
    const merged = mergeEvents(tm, bit);
    expect(merged.status).toBe("soldout");
    expect(merged.sources.sort()).toEqual(["bandsintown", "ticketmaster"]);
  });
});

describe("dedupeBatch / buildEvents end-to-end", () => {
  it("merges the same Berlin show seen on Ticketmaster and Bandsintown", () => {
    const events = buildEvents(
      [
        { adapterSource: "ticketmaster", payload: fixture("ticketmaster_berlin") },
        { adapterSource: "bandsintown", payload: fixture("bandsintown_cairokee") },
      ],
      testResolver,
      noAffiliate,
      fixedNow,
    );

    // Cairokee Berlin (merged from 2 sources) + Cairokee Paris (BIT only).
    // The unknown-artist TM event is dropped.
    expect(events).toHaveLength(2);

    const berlin = events.find((e) => e.city === "Berlin")!;
    expect(berlin.sources.sort()).toEqual(["bandsintown", "ticketmaster"]);
    expect(berlin.artistIds).toEqual(["cairokee"]);

    const paris = events.find((e) => e.city === "Paris")!;
    expect(paris.sources).toEqual(["bandsintown"]);
    expect(paris.status).toBe("soldout");
  });

  it("dedupeBatch is a no-op for distinct keys", () => {
    const a = normalizeEvent(rawCairokee("ticketmaster", { city: "Berlin" }), testResolver, noAffiliate, fixedNow)!;
    const b = normalizeEvent(rawCairokee("ticketmaster", { city: "Paris" }), testResolver, noAffiliate, fixedNow)!;
    const out: NormalizedEvent[] = dedupeBatch([a, b]);
    expect(out).toHaveLength(2);
  });
});

describe("adapters round-trip through normalize", () => {
  it("ticketmaster + bandsintown parse to RawEvents", () => {
    expect(ticketmasterAdapter.parse(fixture("ticketmaster_berlin"))).toHaveLength(2);
    expect(bandsintownAdapter.parse(fixture("bandsintown_cairokee"))).toHaveLength(2);
  });
});
