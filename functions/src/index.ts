import { onSchedule } from "firebase-functions/v2/scheduler";
import { logger } from "firebase-functions";

import { getApp } from "./admin";
import { runCycle } from "./pipeline";

/**
 * OPTIONAL — Cloud Functions schedule. This requires the **Blaze** plan and is
 * NOT the deploy path on the free tier; the free-tier setup runs the identical
 * `runCycle` via `npm run ingest` on a GitHub Actions cron (see
 * `.github/workflows/ingest.yml`). Kept here so upgrading to Blaze is a one-line
 * `firebase deploy --only functions` with no logic changes.
 */
export const scheduledIngest = onSchedule(
  { schedule: "every 6 hours", timeoutSeconds: 540, memory: "512MiB" },
  async () => {
    const app = getApp();
    const result = await runCycle(app.firestore(), app.messaging());
    logger.info("ingest cycle complete", result);
  },
);
