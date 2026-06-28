import { describe, expect, it } from "vitest";

import {
  defaultAffiliateConfig,
  wrapAffiliateUrl,
} from "../src/affiliate";

const config = { ticketmaster: { camefrom: "EUROFEST_123" } };

describe("wrapAffiliateUrl", () => {
  it("appends tracking params for a known source", () => {
    const out = wrapAffiliateUrl(
      "ticketmaster",
      "https://www.ticketmaster.de/event/x",
      config,
    );
    expect(out).toContain("camefrom=EUROFEST_123");
  });

  it("preserves existing query params", () => {
    const out = wrapAffiliateUrl(
      "ticketmaster",
      "https://www.ticketmaster.de/event/x?foo=1",
      config,
    );
    expect(out).toContain("foo=1");
    expect(out).toContain("camefrom=EUROFEST_123");
  });

  it("passes through unknown sources unchanged", () => {
    const url = "https://example.com/e/1";
    expect(wrapAffiliateUrl("eventim", url, config)).toBe(url);
  });

  it("returns undefined/empty input untouched", () => {
    expect(wrapAffiliateUrl("ticketmaster", undefined, config)).toBeUndefined();
  });

  it("leaves non-absolute URLs alone", () => {
    expect(wrapAffiliateUrl("ticketmaster", "not a url", config)).toBe("not a url");
  });
});

describe("defaultAffiliateConfig", () => {
  it("builds config from env vars", () => {
    const cfg = defaultAffiliateConfig({
      EUROFEST_TM_AFFILIATE: "ABC",
    } as NodeJS.ProcessEnv);
    expect(cfg.ticketmaster).toEqual({ camefrom: "ABC" });
  });

  it("is empty when no env vars are set", () => {
    expect(defaultAffiliateConfig({} as NodeJS.ProcessEnv)).toEqual({});
  });
});
