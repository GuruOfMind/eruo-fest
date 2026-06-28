import { IngestFetchers } from "./ingest";

/**
 * Live HTTP fetchers for the scheduled ingest. API keys come from environment
 * config (set via `firebase functions:config` or Secret Manager). Uses the
 * global `fetch` available on Node 20.
 */
export function liveFetchers(env: NodeJS.ProcessEnv = process.env): IngestFetchers {
  const tmKey = env.TICKETMASTER_API_KEY ?? "";
  const bitAppId = env.BANDSINTOWN_APP_ID ?? "";

  return {
    async ticketmasterByCity(city, country) {
      const url = new URL("https://app.ticketmaster.com/discovery/v2/events.json");
      url.searchParams.set("apikey", tmKey);
      url.searchParams.set("city", city);
      if (country) url.searchParams.set("countryCode", country);
      url.searchParams.set("classificationName", "music");
      url.searchParams.set("size", "100");
      const res = await fetch(url);
      if (!res.ok) throw new Error(`Ticketmaster ${res.status}`);
      return res.json();
    },

    async bandsintownByArtist(artistName) {
      const url = new URL(
        `https://rest.bandsintown.com/artists/${encodeURIComponent(artistName)}/events`,
      );
      url.searchParams.set("app_id", bitAppId);
      url.searchParams.set("date", "upcoming");
      const res = await fetch(url);
      if (!res.ok) throw new Error(`Bandsintown ${res.status}`);
      return res.json();
    },
  };
}
