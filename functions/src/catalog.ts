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
  category?: "music" | "comedy";
  isMENA?: boolean;
}

export interface SeedVenue {
  id: string;
  name: string;
  city: string;
  country: string;
}

export const SEED_ARTISTS: SeedArtist[] = [
  // Pop / Tarab mainstays
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
  { id: "mohamed-mounir", name: "Mohamed Mounir", nameAr: "محمد منير", aliases: ["Mounir"], genres: ["Rock", "Pop"] },
  { id: "angham", name: "Angham", nameAr: "أنغام", genres: ["Pop", "Tarab"] },
  { id: "majida-el-roumi", name: "Majida El Roumi", nameAr: "ماجدة الرومي", genres: ["Tarab"] },
  { id: "fairuz", name: "Fairuz", nameAr: "فيروز", genres: ["Tarab"] },
  { id: "wael-kfoury", name: "Wael Kfoury", nameAr: "وائل كفوري", genres: ["Pop"] },
  { id: "ragheb-alama", name: "Ragheb Alama", nameAr: "راغب علامة", genres: ["Pop"] },
  { id: "najwa-karam", name: "Najwa Karam", nameAr: "نجوى كرم", genres: ["Tarab", "Pop"] },
  { id: "nawal-el-zoghbi", name: "Nawal Al Zoghbi", nameAr: "نوال الزغبي", genres: ["Pop"] },
  { id: "carole-samaha", name: "Carole Samaha", nameAr: "كارول سماحة", genres: ["Pop"] },
  { id: "haifa-wehbe", name: "Haifa Wehbe", nameAr: "هيفاء وهبي", genres: ["Pop"] },
  { id: "nassif-zeytoun", name: "Nassif Zeytoun", nameAr: "ناصيف زيتون", genres: ["Pop"] },
  { id: "adham-nabulsi", name: "Adham Nabulsi", nameAr: "أدهم نابلسي", genres: ["Pop"] },
  { id: "tamer-ashour", name: "Tamer Ashour", nameAr: "تامر عاشور", genres: ["Pop"] },
  { id: "amal-maher", name: "Amal Maher", nameAr: "آمال ماهر", genres: ["Tarab", "Pop"] },
  { id: "mohamed-fouad", name: "Mohamed Fouad", nameAr: "محمد فؤاد", genres: ["Pop"] },
  { id: "abu", name: "Abu", nameAr: "أبو", genres: ["Pop"] },
  { id: "carmen-soliman", name: "Carmen Soliman", nameAr: "كارمن سليمان", genres: ["Pop"] },

  // Khaleeji
  { id: "hussain-al-jassmi", name: "Hussain Al Jassmi", nameAr: "حسين الجسمي", genres: ["Khaleeji", "Pop"] },
  { id: "ahlam", name: "Ahlam", nameAr: "أحلام", genres: ["Khaleeji"] },
  { id: "diana-haddad", name: "Diana Haddad", nameAr: "ديانا حداد", genres: ["Khaleeji", "Pop"] },
  { id: "rashed-al-majed", name: "Rashed Al Majed", nameAr: "راشد الماجد", genres: ["Khaleeji"] },
  { id: "abdullah-al-ruwaished", name: "Abdullah Al Ruwaished", nameAr: "عبدالله الرويشد", genres: ["Khaleeji"] },
  { id: "nabeel-shuail", name: "Nabeel Shuail", nameAr: "نبيل شعيل", genres: ["Khaleeji"] },

  // North African (big diaspora draw in Europe)
  { id: "saad-lamjarred", name: "Saad Lamjarred", nameAr: "سعد لمجرد", genres: ["Pop"] },
  { id: "douzi", name: "Douzi", nameAr: "الدوزي", genres: ["Raï", "Pop"] },
  { id: "soolking", name: "Soolking", nameAr: "سولكينغ", genres: ["Rap", "Raï"] },
  { id: "balti", name: "Balti", nameAr: "بلطي", genres: ["Rap"] },
  { id: "emel-mathlouthi", name: "Emel Mathlouthi", nameAr: "آمال المثلوثي", genres: ["Alternative"] },

  // Rap / Mahraganat / new wave
  { id: "saint-levant", name: "Saint Levant", nameAr: "سان ليفان", genres: ["Hip-Hop", "R&B"] },
  { id: "marwan-pablo", name: "Marwan Pablo", nameAr: "مروان بابلو", genres: ["Rap", "Trap"] },
  { id: "wegz", name: "Wegz", nameAr: "ويجز", aliases: ["Wijz"], genres: ["Rap", "Mahraganat"] },
  { id: "marwan-moussa", name: "Marwan Moussa", nameAr: "مروان موسى", genres: ["Rap"] },
  { id: "abyusif", name: "Abyusif", nameAr: "أبيوسف", genres: ["Rap"] },
  { id: "zap-tharwat", name: "Zap Tharwat", nameAr: "زاب ثروت", genres: ["Rap"] },
  { id: "felukah", name: "Felukah", nameAr: "فلوكة", genres: ["Rap", "R&B"] },
  { id: "mohammed-ramadan", name: "Mohamed Ramadan", nameAr: "محمد رمضان", genres: ["Pop", "Rap"] },

  // Indie / Rock
  { id: "cairokee", name: "Cairokee", nameAr: "كايروكي", genres: ["Rock", "Indie"] },
  { id: "massar-egbari", name: "Massar Egbari", nameAr: "مسار إجباري", genres: ["Rock", "Indie"] },
  { id: "sharmoofers", name: "Sharmoofers", nameAr: "شارموفرز", genres: ["Indie", "Pop"] },
  { id: "hamza-namira", name: "Hamza Namira", nameAr: "حمزة نمرة", genres: ["Indie", "Pop"] },
  { id: "mashrou-leila", name: "Mashrou' Leila", nameAr: "مشروع ليلى", genres: ["Indie", "Rock"] },
  { id: "yasmine-hamdan", name: "Yasmine Hamdan", nameAr: "ياسمين حمدان", genres: ["Indie"] },
  { id: "elyanna", name: "Elyanna", nameAr: "إليانا", genres: ["Pop", "Alternative"] },
  { id: "dina-elwedidi", name: "Dina El Wedidi", nameAr: "دينا الوديدي", genres: ["Indie"] },
  { id: "adonis", name: "Adonis", nameAr: "أدونيس", genres: ["Indie", "Rock"] },
  { id: "autostrad", name: "Autostrad", nameAr: "أوتوستراد", genres: ["Indie"] },

  // More Khaleeji / Iraqi
  { id: "mohamed-abdo", name: "Mohammed Abdu", nameAr: "محمد عبده", genres: ["Khaleeji", "Tarab"] },
  { id: "abdul-majeed-abdullah", name: "Abdul Majeed Abdullah", nameAr: "عبدالمجيد عبدالله", genres: ["Khaleeji"] },
  { id: "majid-al-mohandis", name: "Majid Al Mohandis", nameAr: "ماجد المهندس", genres: ["Khaleeji", "Iraqi"] },
  { id: "saif-nabeel", name: "Saif Nabeel", nameAr: "سيف نبيل", genres: ["Iraqi", "Pop"] },
  { id: "rahma-riad", name: "Rahma Riad", nameAr: "رحمة رياض", genres: ["Iraqi", "Pop"] },
  { id: "aseel-hameem", name: "Aseel Hameem", nameAr: "أصيل هميم", genres: ["Iraqi"] },

  // More Egyptian Pop / Shaabi / Mahraganat
  { id: "ramy-sabry", name: "Ramy Sabry", nameAr: "رامي صبري", genres: ["Pop"] },
  { id: "ramy-gamal", name: "Ramy Gamal", nameAr: "رامي جمال", genres: ["Pop"] },
  { id: "bahaa-sultan", name: "Bahaa Sultan", nameAr: "بهاء سلطان", genres: ["Pop"] },
  { id: "hamada-helal", name: "Hamada Helal", nameAr: "حمادة هلال", genres: ["Pop"] },
  { id: "ahmed-saad", name: "Ahmed Saad", nameAr: "أحمد سعد", genres: ["Shaabi", "Pop"] },
  { id: "mahmoud-el-esseily", name: "Mahmoud El Esseily", nameAr: "محمود العسيلي", genres: ["Pop"] },
  { id: "hassan-shakosh", name: "Hassan Shakosh", nameAr: "حسن شاكوش", genres: ["Mahraganat"] },
  { id: "omar-kamal", name: "Omar Kamal", nameAr: "عمر كمال", genres: ["Mahraganat"] },

  // Stand-up comedy (Arab comedians touring Europe / diaspora)
  { id: "bassem-youssef", name: "Bassem Youssef", nameAr: "باسم يوسف", genres: ["Comedy"], category: "comedy" },
  { id: "mo-amer", name: "Mo Amer", nameAr: "مو عامر", genres: ["Comedy"], category: "comedy" },
  { id: "ramy-youssef", name: "Ramy Youssef", nameAr: "رامي يوسف", genres: ["Comedy"], category: "comedy" },
  { id: "maz-jobrani", name: "Maz Jobrani", nameAr: "ماز جبراني", genres: ["Comedy"], category: "comedy" },
  { id: "nemr", name: "Nemr", nameAr: "نمر", aliases: ["Nemr Abou Nassar"], genres: ["Comedy"], category: "comedy" },
  { id: "eman-el-husseini", name: "Eman El Husseini", nameAr: "إيمان الحسيني", genres: ["Comedy"], category: "comedy" },
  { id: "wonho-chung", name: "Wonho Chung", nameAr: "ونهو تشونغ", genres: ["Comedy"], category: "comedy" },
  { id: "ahmed-ahmed", name: "Ahmed Ahmed", nameAr: "أحمد أحمد", genres: ["Comedy"], category: "comedy" },
  { id: "amer-zahr", name: "Amer Zahr", nameAr: "عامر زهر", genres: ["Comedy"], category: "comedy" },
  { id: "hisham-fageeh", name: "Hisham Fageeh", nameAr: "هشام فقيه", genres: ["Comedy"], category: "comedy" },
  { id: "ibraheem-alkhairallah", name: "Ibraheem Alkhairallah", nameAr: "إبراهيم الخير الله", genres: ["Comedy"], category: "comedy" },
  { id: "fahad-albutairi", name: "Fahad Albutairi", nameAr: "فهد البتيري", genres: ["Comedy"], category: "comedy" },
];

export const SEED_VENUES: SeedVenue[] = [
  { id: "columbiahalle-berlin", name: "Columbiahalle", city: "berlin", country: "DE" },
  { id: "tempodrom-berlin", name: "Tempodrom", city: "berlin", country: "DE" },
  { id: "le-trianon-paris", name: "Le Trianon", city: "paris", country: "FR" },
  { id: "olympia-paris", name: "L'Olympia", city: "paris", country: "FR" },
  { id: "o2-forum-london", name: "O2 Forum Kentish Town", city: "london", country: "GB" },
  { id: "paradiso-amsterdam", name: "Paradiso", city: "amsterdam", country: "NL" },
];
