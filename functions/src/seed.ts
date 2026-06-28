import * as admin from "firebase-admin";

import { SEED_ARTISTS, SEED_VENUES } from "./catalog";

/**
 * Writes the curated catalog into Firestore `artists` and `venues`. Idempotent
 * (merge by stable id), so it can be re-run safely whenever the catalog grows.
 */
export async function seedCatalog(
  db: admin.firestore.Firestore,
): Promise<{ artists: number; venues: number }> {
  const batch = db.batch();
  for (const a of SEED_ARTISTS) {
    batch.set(
      db.collection("artists").doc(a.id),
      { ...a, category: a.category ?? "music", isMENA: a.isMENA ?? true },
      { merge: true },
    );
  }
  for (const v of SEED_VENUES) {
    batch.set(db.collection("venues").doc(v.id), v, { merge: true });
  }
  await batch.commit();
  return { artists: SEED_ARTISTS.length, venues: SEED_VENUES.length };
}

// CLI entry: `npm run seed`.
if (require.main === module) {
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const { db } = require("./admin") as typeof import("./admin");
  seedCatalog(db())
    .then((r) => {
      console.log(`Seeded ${r.artists} artists, ${r.venues} venues.`);
      process.exit(0);
    })
    .catch((e) => {
      console.error("Seed failed:", e);
      process.exit(1);
    });
}
