/**
 * Curated launch catalog, mirrored into Firestore by `npm run seed`.
 *
 * Keep in sync with the Flutter seed (`lib/data/seed/mena_artists.dart`,
 * `seed_venues.dart`). The ingestion resolver matches performer names against
 * `name` / `nameAr` / `aliases` here, so add aliases as real-world spellings
 * surface from the source APIs.
 */
export interface SeedArtist {
  id: string;
  name: string;
  nameAr: string;
  aliases?: string[];
  genres: string[];
  isMENA?: boolean;
}

export interface SeedVenue {
  id: string;
  name: string;
  city: string;
  country: string;
}

export const SEED_ARTISTS: SeedArtist[] = [
  { id: "amr-diab", name: "Amr Diab", nameAr: "عمرو دياب", genres: ["Pop"] },
  { id: "elissa", name: "Elissa", nameAr: "إليسا", genres: ["Pop"] },
  { id: "nancy-ajram", name: "Nancy Ajram", nameAr: "نانسي عجرم", genres: ["Pop"] },
  { id: "tamer-hosny", name: "Tamer Hosny", nameAr: "تامر حسني", genres: ["Pop"] },
  { id: "mohammed-hamaki", name: "Mohamed Hamaki", nameAr: "محمد حماقي", aliases: ["Hamaki"], genres: ["Pop"] },
  { id: "assala", name: "Assala Nasri", nameAr: "أصالة نصري", aliases: ["Assala"], genres: ["Tarab"] },
  { id: "kazem-al-saher", name: "Kazem Al Saher", nameAr: "كاظم الساهر", genres: ["Tarab"] },
  { id: "sherine", name: "Sherine", nameAr: "شيرين", aliases: ["Sherine Abdel Wahab"], genres: ["Pop"] },
  { id: "myriam-fares", name: "Myriam Fares", nameAr: "ميريام فارس", genres: ["Pop"] },
  { id: "balqees", name: "Balqees", nameAr: "بلقيس", aliases: ["Balqees Fathi"], genres: ["Khaleeji", "Pop"] },
  { id: "saint-levant", name: "Saint Levant", nameAr: "سان ليفان", genres: ["Hip-Hop", "R&B"] },
  { id: "marwan-pablo", name: "Marwan Pablo", nameAr: "مروان بابلو", genres: ["Rap", "Trap"] },
  { id: "wegz", name: "Wegz", nameAr: "ويجز", aliases: ["Wijz"], genres: ["Rap", "Mahraganat"] },
  { id: "cairokee", name: "Cairokee", nameAr: "كايروكي", genres: ["Rock", "Indie"] },
  { id: "massar-egbari", name: "Massar Egbari", nameAr: "مسار إجباري", genres: ["Rock", "Indie"] },
  { id: "sharmoofers", name: "Sharmoofers", nameAr: "شارموفرز", genres: ["Indie", "Pop"] },
  { id: "mohammed-ramadan", name: "Mohamed Ramadan", nameAr: "محمد رمضان", genres: ["Pop", "Rap"] },
  { id: "carmen-soliman", name: "Carmen Soliman", nameAr: "كارمن سليمان", genres: ["Pop"] },
];

export const SEED_VENUES: SeedVenue[] = [
  { id: "columbiahalle-berlin", name: "Columbiahalle", city: "berlin", country: "DE" },
  { id: "tempodrom-berlin", name: "Tempodrom", city: "berlin", country: "DE" },
  { id: "le-trianon-paris", name: "Le Trianon", city: "paris", country: "FR" },
  { id: "olympia-paris", name: "L'Olympia", city: "paris", country: "FR" },
  { id: "o2-forum-london", name: "O2 Forum Kentish Town", city: "london", country: "GB" },
  { id: "paradiso-amsterdam", name: "Paradiso", city: "amsterdam", country: "NL" },
];
