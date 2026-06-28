import { describe, expect, it } from "vitest";

import { defaultAffiliateConfig } from "../src/affiliate";
import { buildEvents, europeanCountries } from "../src/ingest";
import { testResolver } from "./helpers";

/** Minimal Ticketmaster payload with one DE and one US Cairokee show. */
const payload = {
  _embedded: {
    events: [
      {
        id: "tm-de",
        url: "https://tm.com/de",
        dates: { start: { dateTime: "2026-09-01T19:00:00Z" }, status: { code: "onsale" } },
        _embedded: {
          venues: [{ name: "Columbiahalle", city: { name: "Berlin" }, country: { countryCode: "DE" } }],
          attractions: [{ name: "Cairokee" }],
        },
      },
      {
        id: "tm-us",
        url: "https://tm.com/us",
        dates: { start: { dateTime: "2026-10-01T19:00:00Z" }, status: { code: "onsale" } },
        _embedded: {
          venues: [{ name: "The Fillmore", city: { name: "Detroit" }, country: { countryCode: "US" } }],
          attractions: [{ name: "Cairokee" }],
        },
      },
    ],
  },
};

describe("buildEvents country filter", () => {
  const affiliate = defaultAffiliateConfig({});
  const payloads = [{ adapterSource: "ticketmaster", payload }];

  it("keeps every country when no filter is given", () => {
    const events = buildEvents(payloads, testResolver, affiliate);
    expect(events).toHaveLength(2);
  });

  it("drops non-European events when an allow-list is given", () => {
    const events = buildEvents(
      payloads,
      testResolver,
      affiliate,
      undefined,
      europeanCountries(),
    );
    expect(events).toHaveLength(1);
    expect(events[0].country).toBe("DE");
    expect(events[0].city).toBe("Berlin");
  });
});

describe("europeanCountries", () => {
  it("reads a custom allow-list from the environment", () => {
    expect(europeanCountries({ EUROFEST_COUNTRIES: "de, fr" })).toEqual(
      new Set(["DE", "FR"]),
    );
  });

  it("defaults to a European set including GB", () => {
    expect(europeanCountries({}).has("GB")).toBe(true);
  });
});
