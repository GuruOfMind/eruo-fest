import { describe, expect, it } from "vitest";

import { ticketmasterAdapter } from "../src/adapters/ticketmaster";
import { bandsintownAdapter } from "../src/adapters/bandsintown";
import { fixture } from "./helpers";

describe("ticketmasterAdapter", () => {
  const events = ticketmasterAdapter.parse(fixture("ticketmaster_berlin"));

  it("parses both events", () => {
    expect(events).toHaveLength(2);
  });

  it("maps fields for the Cairokee show", () => {
    const e = events[0];
    expect(e).toMatchObject({
      source: "ticketmaster",
      sourceEventId: "tm-cairokee-berlin",
      artistNames: ["Cairokee"],
      venueName: "Columbiahalle",
      city: "Berlin",
      country: "DE",
      startsAt: "2026-09-12T19:00:00Z",
      status: "onsale",
      priceFrom: 45.0,
      currency: "EUR",
    });
    expect(e.lat).toBeCloseTo(52.4839);
  });
});

describe("bandsintownAdapter", () => {
  const events = bandsintownAdapter.parse(fixture("bandsintown_cairokee"));

  it("derives status from the Tickets offer", () => {
    expect(events[0].status).toBe("onsale"); // available
    expect(events[1].status).toBe("soldout"); // sold out
  });

  it("uses the offer url as the ticket url", () => {
    expect(events[0].ticketUrl).toContain("/t/123");
  });
});
