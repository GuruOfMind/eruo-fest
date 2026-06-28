import { ArtistResolver } from "./types";

/**
 * Performer-name matching for noisy source data. Ticketmaster attraction names
 * and Eventim tour titles rarely equal our catalog name exactly — e.g.
 * "Helene Fischer - 360° Stadion Tour 2026" or "AMR DIAB LIVE". We normalize
 * (Latin + Arabic) and match the catalog name as a contiguous run of tokens
 * inside the source name.
 */

/** Lowercase, strip Latin diacritics + Arabic tashkeel, unify Arabic letter
 * variants, drop punctuation, collapse whitespace. */
export function normalizeName(input: string): string {
  return input
    .toLowerCase()
    .normalize("NFKD")
    .replace(/[̀-ͯ]/g, "") // Latin combining marks
    .replace(/[ؐ-ًؚ-ٰٟ]/g, "") // Arabic tashkeel
    .replace(/[آأإٱ]/g, "ا") // آأإٱ -> ا
    .replace(/ى/g, "ي") // ى -> ي
    .replace(/ة/g, "ه") // ة -> ه
    .replace(/[^a-z0-9؀-ۿ]+/g, " ") // non-alnum (keep Arabic block)
    .trim()
    .replace(/\s+/g, " ");
}

function tokensOf(input: string): string[] {
  const n = normalizeName(input);
  return n ? n.split(" ") : [];
}

/** Is `needle` a contiguous sub-sequence of `hay`? */
function containsTokens(hay: string[], needle: string[]): boolean {
  if (needle.length === 0 || needle.length > hay.length) return false;
  for (let i = 0; i + needle.length <= hay.length; i++) {
    let ok = true;
    for (let j = 0; j < needle.length; j++) {
      if (hay[i + j] !== needle[j]) {
        ok = false;
        break;
      }
    }
    if (ok) return true;
  }
  return false;
}

/**
 * A catalog name is "specific enough" to fuzzy-match by substring only if it is
 * multi-token or a single token of ≥4 chars — avoids generic short names (e.g.
 * "Abu") matching unrelated events.
 */
function isSpecific(tokens: string[]): boolean {
  return tokens.length >= 2 || (tokens.length === 1 && tokens[0].length >= 4);
}

interface CatalogName {
  id: string;
  tokens: string[];
}

/**
 * Builds a resolver: exact normalized match first, then the most specific
 * catalog name that appears as a contiguous token run inside the query.
 */
export function buildMatcher(
  artists: { id: string; name?: string; nameAr?: string; aliases?: string[] }[],
): ArtistResolver {
  const exact = new Map<string, string>();
  const entries: CatalogName[] = [];

  for (const a of artists) {
    for (const key of [a.name, a.nameAr, ...(a.aliases ?? [])]) {
      if (!key) continue;
      const norm = normalizeName(key);
      if (norm) exact.set(norm, a.id);
      const tk = tokensOf(key);
      if (isSpecific(tk)) entries.push({ id: a.id, tokens: tk });
    }
  }
  // Prefer longer (more specific) names when several could match.
  entries.sort((x, y) => y.tokens.length - x.tokens.length);

  return (name: string): string | null => {
    const norm = normalizeName(name);
    if (!norm) return null;
    const hit = exact.get(norm);
    if (hit) return hit;
    const hay = norm.split(" ");
    for (const e of entries) {
      if (containsTokens(hay, e.tokens)) return e.id;
    }
    return null;
  };
}
