// Load functions/.env for local runs; harmless if dotenv isn't installed (CI
// injects env directly).
try {
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  require("dotenv").config();
} catch {
  /* optional */
}

import { db, messaging } from "./admin";
import { runCycle } from "./pipeline";

/**
 * Standalone ingest + notify runner — the free-tier replacement for Cloud
 * Functions. Invoked by `npm run ingest` (locally) or the GitHub Actions cron.
 *
 * Credentials come from Application Default Credentials
 * (`GOOGLE_APPLICATION_CREDENTIALS` → a service-account key). Source API keys
 * and affiliate ids come from environment variables (see `.env.example`).
 */
async function main(): Promise<void> {
  const result = await runCycle(db(), messaging());
  console.log(
    `cycle complete — upserted=${result.upserted} created=${result.created} ` +
      `notified=${result.notified} pushes=${result.pushes}`,
  );
}

main()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error("ingest runner failed:", e);
    process.exit(1);
  });
