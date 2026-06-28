import * as admin from "firebase-admin";

let app: admin.app.App | undefined;

/**
 * Initializes the Admin SDK once, using Application Default Credentials —
 * `GOOGLE_APPLICATION_CREDENTIALS` (a service-account key path) locally and in
 * CI, or the runtime service account when run inside GCP. Free-tier safe: the
 * Admin SDK talks to Firestore/FCM directly, no Cloud Functions required.
 */
export function getApp(): admin.app.App {
  app ??= admin.initializeApp();
  return app;
}

export const db = (): admin.firestore.Firestore => getApp().firestore();
export const messaging = (): admin.messaging.Messaging => getApp().messaging();
