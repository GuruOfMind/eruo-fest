import { describe, expect, it } from "vitest";

import {
  composeMessage,
  FollowerProfile,
  isQuietHour,
  matchFollowers,
} from "../src/notify";
import { NormalizedEvent } from "../src/types";

const event: NormalizedEvent = {
  artistIds: ["cairokee"],
  venueId: "columbiahalle-berlin",
  venueName: "Columbiahalle",
  city: "berlin",
  country: "DE",
  startsAt: "2026-09-01T19:00:00.000Z",
  status: "onsale",
  sources: ["ticketmaster"],
  dedupeKey: "2026-09-01|berlin|cairokee",
  announcedAt: "2026-06-28T00:00:00.000Z",
};

function follower(over: Partial<FollowerProfile> = {}): FollowerProfile {
  return {
    uid: "u1",
    locale: "ar",
    follows: new Set(["cairokee"]),
    fcmTokens: ["t1"],
    mutedCities: new Set(),
    enabled: true,
    ...over,
  };
}

describe("matchFollowers", () => {
  it("matches a follower of one of the event's artists", () => {
    expect(matchFollowers(event, [follower()])).toHaveLength(1);
  });

  it("skips followers who don't follow any of the artists", () => {
    const f = follower({ follows: new Set(["wegz"]) });
    expect(matchFollowers(event, [f])).toHaveLength(0);
  });

  it("skips followers with notifications disabled", () => {
    expect(matchFollowers(event, [follower({ enabled: false })])).toHaveLength(0);
  });

  it("skips followers who muted the event's city", () => {
    const f = follower({ mutedCities: new Set(["berlin"]) });
    expect(matchFollowers(event, [f])).toHaveLength(0);
  });
});

describe("isQuietHour", () => {
  it("is false when quiet hours are unset", () => {
    expect(isQuietHour(new Date("2026-01-01T03:00:00"), undefined, undefined)).toBe(
      false,
    );
  });

  it("handles a daytime window", () => {
    expect(isQuietHour(new Date("2026-01-01T10:00:00"), 9, 17)).toBe(true);
    expect(isQuietHour(new Date("2026-01-01T18:00:00"), 9, 17)).toBe(false);
  });

  it("handles an overnight window", () => {
    expect(isQuietHour(new Date("2026-01-01T23:00:00"), 22, 7)).toBe(true);
    expect(isQuietHour(new Date("2026-01-01T03:00:00"), 22, 7)).toBe(true);
    expect(isQuietHour(new Date("2026-01-01T12:00:00"), 22, 7)).toBe(false);
  });
});

describe("composeMessage", () => {
  const names = { cairokee: { name: "Cairokee", nameAr: "كايروكي" } };

  it("uses Arabic name + title for ar", () => {
    const m = composeMessage(event, "ar", names);
    expect(m.body).toContain("كايروكي");
    expect(m.title).toContain("حفلة");
  });

  it("uses Latin name + English title for en", () => {
    const m = composeMessage(event, "en", names);
    expect(m.body).toContain("Cairokee");
    expect(m.title).toContain("New event");
  });
});
