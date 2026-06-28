import { writeFileSync } from "node:fs";

import { SEED_ARTISTS } from "./catalog";

/**
 * Dumps the catalog (id, names, aliases, category) to JSON so the Python
 * Eventim fetcher (`eventim/fetch_eventim.py`) can search each artist without
 * needing Firestore access. Run: `npm run export-catalog -- <path>`.
 */
const out = process.argv[2] ?? "catalog.export.json";
const data = SEED_ARTISTS.map((a) => ({
  id: a.id,
  name: a.name,
  nameAr: a.nameAr,
  aliases: a.aliases ?? [],
  category: a.category ?? "music",
}));
writeFileSync(out, JSON.stringify(data, null, 2));
console.log(`exported ${data.length} artists to ${out}`);
