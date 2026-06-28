import { describe, expect, it } from "vitest";

import { eventimAdapter } from "../src/adapters/eventim";
import { defaultAffiliateConfig } from "../src/affiliate";
import { buildEvents, europeanCountries } from "../src/ingest";
import { buildMatcher } from "../src/matching";
import { fixture } from "./helpers";

const catalog = [{ id: "amr-diab", name: "Amr Diab", nameAr: "عمرو دياب" }];

describe("eventimAdapter", () => {
  it("parses raw rows and maps Eventim status", () => {
    const raw = eventimAdapter.parse(fixture("eventim_amrdiab"));
    expect(raw).toHaveLength(2);
    expect(raw[0].source).toBe("eventim");
    expect(raw[0].status).toBe("onsale"); // "Available"
    expect(raw[1].status).toBe("cancelled");
    expect(raw[0].city).toBe("Berlin");
  });

  it("resolves the artist from a noisy Eventim tour title and drops non-catalog", () => {
    const events = buildEvents(
      [{ adapterSource: "eventim", payload: fixture("eventim_amrdiab") }],
      buildMatcher(catalog),
      defaultAffiliateConfig({}),
      undefined,
      europeanCountries(),
    );
    // "Amr Diab - Live in Berlin 2026" resolves; "Schlager Nacht" does not.
    expect(events).toHaveLength(1);
    expect(events[0].artistIds).toEqual(["amr-diab"]);
    expect(events[0].sources).toEqual(["eventim"]);
    expect(events[0].city).toBe("Berlin");
  });
});
