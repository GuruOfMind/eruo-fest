import { describe, expect, it } from "vitest";

import { buildMatcher, normalizeName } from "../src/matching";

const artists = [
  { id: "amr-diab", name: "Amr Diab", nameAr: "عمرو دياب" },
  { id: "cairokee", name: "Cairokee", nameAr: "كايروكي" },
  { id: "kazem-al-saher", name: "Kazem Al Saher", nameAr: "كاظم الساهر", aliases: ["Kadim Al Sahir"] },
  { id: "abu", name: "Abu", nameAr: "أبو" },
  { id: "wegz", name: "Wegz", nameAr: "ويجز" },
];

describe("normalizeName", () => {
  it("strips Latin diacritics and case", () => {
    expect(normalizeName("Mylène  FARMER")).toBe("mylene farmer");
  });

  it("strips Arabic tashkeel and unifies letters", () => {
    // أ -> ا, tashkeel removed
    expect(normalizeName("أَنَا")).toBe("انا");
  });
});

describe("buildMatcher", () => {
  const match = buildMatcher(artists);

  it("matches exact names (either script)", () => {
    expect(match("Amr Diab")).toBe("amr-diab");
    expect(match("عمرو دياب")).toBe("amr-diab");
  });

  it("matches inside a noisy tour/attraction title", () => {
    expect(match("AMR DIAB - Live in Berlin 2026")).toBe("amr-diab");
    expect(match("Cairokee Europe Tour 2026")).toBe("cairokee");
  });

  it("matches a transliteration alias", () => {
    expect(match("Kadim Al Sahir")).toBe("kazem-al-saher");
  });

  it("matches Arabic name within a longer Arabic title", () => {
    expect(match("حفل عمرو دياب في برلين")).toBe("amr-diab");
  });

  it("does not match a too-generic short name as a substring", () => {
    // "Abu" (3 chars) must not match "Abu Dhabi Festival".
    expect(match("Abu Dhabi Festival")).toBeNull();
  });

  it("returns null for unrelated names", () => {
    expect(match("Taylor Swift")).toBeNull();
  });
});
