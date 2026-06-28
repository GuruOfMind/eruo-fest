// Load functions/.env (GOOGLE_APPLICATION_CREDENTIALS, API keys) before the
// Admin SDK reads credentials. Harmless if dotenv isn't installed (CI injects
// env directly).
try {
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  require("dotenv").config();
} catch {
  /* optional */
}

import * as admin from "firebase-admin";

let app: admin.app.App | undefined;

/**
 * Initializes the Admin SDK once, using Application Default Credentials —
 * `GOOGLE_APPLICATION_CREDENTIALS` (a service-account key path) locally and in
 * CI, or the runtime service account when run inside GCP. Free-tier safe: the
 * Admin SDK talks to Firestore/FCM directly, no Cloud Functions required.
 */
export function getApp(): admin.app.App {
  if (!app) {
    app = admin.initializeApp();
    // Optional event fields (price, currency, lat/lng) are often undefined;
    // ignore them rather than throwing on write.
    app.firestore().settings({ ignoreUndefinedProperties: true });
  }
  return app;
}

export const db = (): admin.firestore.Firestore => getApp().firestore();
export const messaging = (): admin.messaging.Messaging => getApp().messaging();
