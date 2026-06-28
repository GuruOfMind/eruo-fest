import * as admin from "firebase-admin";

import { liveFetchers } from "./fetchers";
import { runIngest } from "./ingest";
import { ArtistName, fanOut, loadFollowers } from "./notify";

/**
 * One full ingest + notify cycle, shared by the standalone runner
 * (`npm run ingest`, free tier) and the optional Cloud Functions schedule.
 * Pulls sources → upserts events → fans out notifications for newly-announced
 * events to their followers.
 */
export async function runCycle(
  db: admin.firestore.Firestore,
  messaging: admin.messaging.Messaging,
): Promise<{ upserted: number; created: number; notified: number; pushes: number }> {
  const { upserted, created } = await runIngest(db, liveFetchers());

  if (created.length === 0) {
    return { upserted, created: 0, notified: 0, pushes: 0 };
  }

  const artistsSnap = await db.collection("artists").get();
  const artists: Record<string, ArtistName> = {};
  artistsSnap.forEach((a) => {
    artists[a.id] = {
      name: (a.get("name") as string) ?? a.id,
      nameAr: (a.get("nameAr") as string) ?? a.id,
    };
  });

  const followers = await loadFollowers(db);
  const { notified, pushes } = await fanOut(
    db,
    messaging,
    created,
    followers,
    artists,
  );

  return { upserted, created: created.length, notified, pushes };
}
