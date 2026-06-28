/**
 * Affiliate link wrapping. Centralised so every "Book" link the app shows
 * carries our tracking params for the right partner. Kept pure (config is
 * injected) so it is unit-testable; `defaultAffiliateConfig` reads env.
 */

/** Query params to append per source, keyed by source name. */
export type AffiliateConfig = Record<string, Record<string, string>>;

/**
 * Returns [url] with the partner's tracking params applied. Existing params are
 * preserved; our params win on conflict. Unknown sources pass through
 * unchanged. Invalid/empty URLs are returned as-is.
 */
export function wrapAffiliateUrl(
  source: string,
  url: string | undefined,
  config: AffiliateConfig,
): string | undefined {
  if (!url) return url;
  const params = config[source];
  if (!params || Object.keys(params).length === 0) return url;
  try {
    const u = new URL(url);
    for (const [k, v] of Object.entries(params)) {
      u.searchParams.set(k, v);
    }
    return u.toString();
  } catch {
    return url; // not an absolute URL — leave untouched
  }
}

/** Builds the config from environment variables (set in functions config). */
export function defaultAffiliateConfig(
  env: NodeJS.ProcessEnv = process.env,
): AffiliateConfig {
  const config: AffiliateConfig = {};
  if (env.EUROFEST_TM_AFFILIATE) {
    // Ticketmaster distributed-commerce affiliate identifier.
    config.ticketmaster = { camefrom: env.EUROFEST_TM_AFFILIATE };
  }
  if (env.EUROFEST_BIT_AFFILIATE) {
    config.bandsintown = { app_id: env.EUROFEST_BIT_AFFILIATE };
  }
  if (env.EUROFEST_EVENTIM_AFFILIATE) {
    config.eventim = { affiliate: env.EUROFEST_EVENTIM_AFFILIATE };
  }
  return config;
}
