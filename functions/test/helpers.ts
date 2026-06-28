import { readFileSync } from "node:fs";
import { join } from "node:path";

import { ArtistResolver } from "../src/types";

export function fixture(name: string): unknown {
  return JSON.parse(
    readFileSync(join(__dirname, "fixtures", `${name}.json`), "utf-8"),
  );
}

/** Test resolver covering the seed names used in fixtures. */
export const testResolver: ArtistResolver = (name) => {
  const map: Record<string, string> = {
    cairokee: "cairokee",
    "كايروكي": "cairokee",
    wegz: "wegz",
  };
  return map[name.trim().toLowerCase()] ?? null;
};
