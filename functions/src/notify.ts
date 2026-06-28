import * as admin from "firebase-admin";

import { NormalizedEvent } from "./types";

/** A user's notification-relevant state, loaded once per ingest run. */
export interface FollowerProfile {
  uid: string;
  locale: string;
  follows: Set<string>; // artistIds the user follows with notify enabled
  fcmTokens: string[];
  mutedCities: Set<string>;
  enabled: boolean; // master notification switch
  quietStart?: number; // hour 0–23, inclusive
  quietEnd?: number; // hour 0–23, exclusive
}

/** Minimal artist display info for composing notification text. */
export interface ArtistName {
  name: string;
  nameAr: string;
}

/**
 * Loads every user with their follows, tokens, and notification prefs. At
 * launch scale this in-memory join is cheap and — crucially — needs no
 * collection-group indexes, keeping us on the free tier.
 */
export async function loadFollowers(
  db: admin.firestore.Firestore,
): Promise<FollowerProfile[]> {
  const usersSnap = await db.collection("users").get();
  const profiles: FollowerProfile[] = [];
  for (const u of usersSnap.docs) {
    const followsSnap = await u.ref.collection("follows").get();
    const follows = new Set<string>();
    followsSnap.forEach((f) => {
      if (f.get("notify") !== false) follows.add(f.id);
    });
    const prefs = (u.get("notifPrefs") as Record<string, unknown>) ?? {};
    profiles.push({
      uid: u.id,
      locale: (u.get("locale") as string) ?? "ar",
      follows,
      fcmTokens: ((u.get("fcmTokens") as string[]) ?? []).filter(Boolean),
      mutedCities: new Set((prefs.mutedCities as string[]) ?? []),
      enabled: prefs.enabled !== false,
      quietStart: prefs.quietStart as number | undefined,
      quietEnd: prefs.quietEnd as number | undefined,
    });
  }
  return profiles;
}

/**
 * Pure: which followers should be notified for an event. A follower matches
 * when notifications are on, the event's city isn't muted, and they follow at
 * least one of the event's artists. Unit-testable without Firestore.
 */
export function matchFollowers(
  event: NormalizedEvent,
  followers: FollowerProfile[],
): FollowerProfile[] {
  return followers.filter(
    (f) =>
      f.enabled &&
      !f.mutedCities.has(event.city) &&
      event.artistIds.some((id) => f.follows.has(id)),
  );
}

/** Pure: is `date`'s local hour inside the user's quiet-hours window? */
export function isQuietHour(
  date: Date,
  quietStart?: number,
  quietEnd?: number,
): boolean {
  if (quietStart == null || quietEnd == null || quietStart === quietEnd) {
    return false;
  }
  const h = date.getHours();
  // Handles overnight windows (e.g. 22 → 7).
  return quietStart < quietEnd
    ? h >= quietStart && h < quietEnd
    : h >= quietStart || h < quietEnd;
}

/** Pure: localized push title/body for a new-event notification. */
export function composeMessage(
  event: NormalizedEvent,
  locale: string,
  artists: Record<string, ArtistName>,
): { title: string; body: string } {
  const ar = locale === "ar";
  const names = event.artistIds
    .map((id) => (ar ? artists[id]?.nameAr : artists[id]?.name) ?? id)
    .join(ar ? "، " : ", ");
  const where = event.venueName ? `${event.venueName} · ${event.city}` : event.city;
  return ar
    ? { title: "🎵 حفلة جديدة!", body: `${names} — ${where}` }
    : { title: "🎵 New event!", body: `${names} — ${where}` };
}

/**
 * Writes an inbox notification per matched follower and sends an FCM multicast
 * to their devices. Quiet hours suppress the push but still record the inbox
 * item. Prunes FCM tokens that the service reports as unregistered.
 */
export async function fanOut(
  db: admin.firestore.Firestore,
  messaging: admin.messaging.Messaging,
  events: NormalizedEvent[],
  followers: FollowerProfile[],
  artists: Record<string, ArtistName>,
  now: Date = new Date(),
): Promise<{ notified: number; pushes: number }> {
  let notified = 0;
  let pushes = 0;

  for (const event of events) {
    for (const f of matchFollowers(event, followers)) {
      await db
        .collection("users")
        .doc(f.uid)
        .collection("notifications")
        .add({
          eventId: event.dedupeKey,
          type: "new_event",
          artistIds: event.artistIds,
          city: event.city,
          read: false,
          createdAt: now.toISOString(),
        });
      notified++;

      const quiet = isQuietHour(now, f.quietStart, f.quietEnd);
      if (quiet || f.fcmTokens.length === 0) continue;

      const { title, body } = composeMessage(event, f.locale, artists);
      const resp = await messaging.sendEachForMulticast({
        tokens: f.fcmTokens,
        notification: { title, body },
        data: { eventId: event.dedupeKey, type: "new_event" },
      });
      pushes += resp.successCount;
      await pruneDeadTokens(db, f, resp);
    }
  }
  return { notified, pushes };
}

/** Removes tokens FCM reports as permanently invalid, to keep the array clean. */
async function pruneDeadTokens(
  db: admin.firestore.Firestore,
  f: FollowerProfile,
  resp: admin.messaging.BatchResponse,
): Promise<void> {
  const dead: string[] = [];
  resp.responses.forEach((r, i) => {
    const code = r.error?.code;
    if (
      code === "messaging/registration-token-not-registered" ||
      code === "messaging/invalid-registration-token"
    ) {
      dead.push(f.fcmTokens[i]);
    }
  });
  if (dead.length) {
    await db
      .collection("users")
      .doc(f.uid)
      .update({ fcmTokens: admin.firestore.FieldValue.arrayRemove(...dead) });
  }
}
