import { IngestFetchers } from "./ingest";

const sleep = (ms: number): Promise<void> =>
  new Promise((r) => setTimeout(r, ms));

/**
 * GET JSON with a minimum spacing between calls (to respect per-second rate
 * limits) and exponential backoff on HTTP 429. The Ticketmaster free tier
 * allows ~5 req/s, so a single shared throttle keeps us under it.
 */
function rateLimitedGetter(minSpacingMs: number) {
  let last = 0;
  return async function get(url: URL, label: string, retries = 4): Promise<unknown> {
    for (let attempt = 0; ; attempt++) {
      const wait = last + minSpacingMs - Date.now();
      if (wait > 0) await sleep(wait);
      last = Date.now();

      const res = await fetch(url);
      if (res.status === 429 && attempt < retries) {
        const retryAfter = Number(res.headers.get("retry-after"));
        await sleep(
          Number.isFinite(retryAfter) && retryAfter > 0
            ? retryAfter * 1000
            : 1000 * 2 ** attempt,
        );
        continue;
      }
      if (!res.ok) throw new Error(`${label} ${res.status}`);
      return res.json();
    }
  };
}

/**
 * Live HTTP fetchers for the ingest runner. API keys come from environment
 * variables (a local `.env` or CI secrets). Uses the global `fetch` on Node 20.
 */
export function liveFetchers(env: NodeJS.ProcessEnv = process.env): IngestFetchers {
  const tmKey = env.TICKETMASTER_API_KEY ?? "";
  const bitAppId = env.BANDSINTOWN_APP_ID ?? "";
  const get = rateLimitedGetter(250); // ≤4 req/s, safely under TM's limit

  const fetchers: IngestFetchers = {
    async ticketmasterByKeyword(keyword) {
      const url = new URL("https://app.ticketmaster.com/discovery/v2/events.json");
      url.searchParams.set("apikey", tmKey);
      url.searchParams.set("keyword", keyword);
      url.searchParams.set("classificationName", "music");
      url.searchParams.set("size", "50");
      return get(url, "Ticketmaster");
    },
  };

  // Only enable Bandsintown when an app id is configured.
  if (bitAppId) {
    fetchers.bandsintownByArtist = async (artistName) => {
      const url = new URL(
        `https://rest.bandsintown.com/artists/${encodeURIComponent(artistName)}/events`,
      );
      url.searchParams.set("app_id", bitAppId);
      url.searchParams.set("date", "upcoming");
      return get(url, "Bandsintown");
    };
  }

  return fetchers;
}
