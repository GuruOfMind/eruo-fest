import { existsSync, readFileSync } from "node:fs";

import * as admin from "firebase-admin";

import { liveFetchers } from "./fetchers";
import { runIngest } from "./ingest";
import { ArtistName, fanOut, loadFollowers } from "./notify";

/**
 * Loads pre-fetched Eventim raw events from `EVENTIM_RAW_PATH` (written by the
 * Python `fetch_eventim.py` step). Returns an empty list when unset/missing so
 * the runner works Ticketmaster-only.
 */
function eventimPayloads(): { adapterSource: string; payload: unknown }[] {
  const path = process.env.EVENTIM_RAW_PATH;
  if (!path || !existsSync(path)) return [];
  try {
    const payload = JSON.parse(readFileSync(path, "utf-8"));
    const count = Array.isArray(payload) ? payload.length : 0;
    console.log(`eventim: loaded ${count} raw events from ${path}`);
    return [{ adapterSource: "eventim", payload }];
  } catch (e) {
    console.warn(`eventim: failed to read ${path}:`, (e as Error).message);
    return [];
  }
}

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
  const { upserted, created } = await runIngest(
    db,
    liveFetchers(),
    undefined,
    eventimPayloads(),
  );

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
