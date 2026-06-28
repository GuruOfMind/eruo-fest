import '../../models/artist.dart';

/// Curated launch catalog of MENA artists who tour (or could tour) Europe.
///
/// This is the **offline fallback**. The live catalog is the `artists`
/// Firestore collection (seeded from `functions/src/catalog.ts`, which must be
/// kept in sync with this list) and read via `artistsProvider`; the app shows
/// this seed only until Firestore loads or when running offline.
const List<Artist> kMenaArtistsSeed = [
  // — Pop / Tarab mainstays —
  Artist(id: 'amr-diab', name: 'Amr Diab', nameAr: 'عمرو دياب', genres: ['Pop']),
  Artist(id: 'elissa', name: 'Elissa', nameAr: 'إليسا', genres: ['Pop']),
  Artist(id: 'nancy-ajram', name: 'Nancy Ajram', nameAr: 'نانسي عجرم', genres: ['Pop']),
  Artist(id: 'tamer-hosny', name: 'Tamer Hosny', nameAr: 'تامر حسني', genres: ['Pop']),
  Artist(id: 'mohammed-hamaki', name: 'Mohamed Hamaki', nameAr: 'محمد حماقي', aliases: ['Hamaki'], genres: ['Pop']),
  Artist(id: 'assala', name: 'Assala Nasri', nameAr: 'أصالة نصري', aliases: ['Assala'], genres: ['Tarab']),
  Artist(id: 'kazem-al-saher', name: 'Kazem Al Saher', nameAr: 'كاظم الساهر', genres: ['Tarab']),
  Artist(id: 'sherine', name: 'Sherine', nameAr: 'شيرين', aliases: ['Sherine Abdel Wahab'], genres: ['Pop']),
  Artist(id: 'myriam-fares', name: 'Myriam Fares', nameAr: 'ميريام فارس', genres: ['Pop']),
  Artist(id: 'balqees', name: 'Balqees', nameAr: 'بلقيس', aliases: ['Balqees Fathi'], genres: ['Khaleeji', 'Pop']),
  Artist(id: 'mohamed-mounir', name: 'Mohamed Mounir', nameAr: 'محمد منير', aliases: ['Mounir'], genres: ['Rock', 'Pop']),
  Artist(id: 'angham', name: 'Angham', nameAr: 'أنغام', genres: ['Pop', 'Tarab']),
  Artist(id: 'majida-el-roumi', name: 'Majida El Roumi', nameAr: 'ماجدة الرومي', genres: ['Tarab']),
  Artist(id: 'fairuz', name: 'Fairuz', nameAr: 'فيروز', genres: ['Tarab']),
  Artist(id: 'wael-kfoury', name: 'Wael Kfoury', nameAr: 'وائل كفوري', genres: ['Pop']),
  Artist(id: 'ragheb-alama', name: 'Ragheb Alama', nameAr: 'راغب علامة', genres: ['Pop']),
  Artist(id: 'najwa-karam', name: 'Najwa Karam', nameAr: 'نجوى كرم', genres: ['Tarab', 'Pop']),
  Artist(id: 'nawal-el-zoghbi', name: 'Nawal Al Zoghbi', nameAr: 'نوال الزغبي', genres: ['Pop']),
  Artist(id: 'carole-samaha', name: 'Carole Samaha', nameAr: 'كارول سماحة', genres: ['Pop']),
  Artist(id: 'haifa-wehbe', name: 'Haifa Wehbe', nameAr: 'هيفاء وهبي', genres: ['Pop']),
  Artist(id: 'nassif-zeytoun', name: 'Nassif Zeytoun', nameAr: 'ناصيف زيتون', genres: ['Pop']),
  Artist(id: 'adham-nabulsi', name: 'Adham Nabulsi', nameAr: 'أدهم نابلسي', genres: ['Pop']),
  Artist(id: 'tamer-ashour', name: 'Tamer Ashour', nameAr: 'تامر عاشور', genres: ['Pop']),
  Artist(id: 'amal-maher', name: 'Amal Maher', nameAr: 'آمال ماهر', genres: ['Tarab', 'Pop']),
  Artist(id: 'mohamed-fouad', name: 'Mohamed Fouad', nameAr: 'محمد فؤاد', genres: ['Pop']),
  Artist(id: 'abu', name: 'Abu', nameAr: 'أبو', genres: ['Pop']),
  Artist(id: 'carmen-soliman', name: 'Carmen Soliman', nameAr: 'كارمن سليمان', genres: ['Pop']),

  // — Khaleeji —
  Artist(id: 'hussain-al-jassmi', name: 'Hussain Al Jassmi', nameAr: 'حسين الجسمي', genres: ['Khaleeji', 'Pop']),
  Artist(id: 'ahlam', name: 'Ahlam', nameAr: 'أحلام', genres: ['Khaleeji']),
  Artist(id: 'diana-haddad', name: 'Diana Haddad', nameAr: 'ديانا حداد', genres: ['Khaleeji', 'Pop']),
  Artist(id: 'rashed-al-majed', name: 'Rashed Al Majed', nameAr: 'راشد الماجد', genres: ['Khaleeji']),
  Artist(id: 'abdullah-al-ruwaished', name: 'Abdullah Al Ruwaished', nameAr: 'عبدالله الرويشد', genres: ['Khaleeji']),
  Artist(id: 'nabeel-shuail', name: 'Nabeel Shuail', nameAr: 'نبيل شعيل', genres: ['Khaleeji']),

  // — North African (big diaspora draw in Europe) —
  Artist(id: 'saad-lamjarred', name: 'Saad Lamjarred', nameAr: 'سعد لمجرد', genres: ['Pop']),
  Artist(id: 'douzi', name: 'Douzi', nameAr: 'الدوزي', genres: ['Raï', 'Pop']),
  Artist(id: 'soolking', name: 'Soolking', nameAr: 'سولكينغ', genres: ['Rap', 'Raï']),
  Artist(id: 'balti', name: 'Balti', nameAr: 'بلطي', genres: ['Rap']),
  Artist(id: 'emel-mathlouthi', name: 'Emel Mathlouthi', nameAr: 'آمال المثلوثي', genres: ['Alternative']),

  // — Rap / Mahraganat / new wave —
  Artist(id: 'saint-levant', name: 'Saint Levant', nameAr: 'سان ليفان', genres: ['Hip-Hop', 'R&B']),
  Artist(id: 'marwan-pablo', name: 'Marwan Pablo', nameAr: 'مروان بابلو', genres: ['Rap', 'Trap']),
  Artist(id: 'wegz', name: 'Wegz', nameAr: 'ويجز', aliases: ['Wijz'], genres: ['Rap', 'Mahraganat']),
  Artist(id: 'marwan-moussa', name: 'Marwan Moussa', nameAr: 'مروان موسى', genres: ['Rap']),
  Artist(id: 'abyusif', name: 'Abyusif', nameAr: 'أبيوسف', genres: ['Rap']),
  Artist(id: 'zap-tharwat', name: 'Zap Tharwat', nameAr: 'زاب ثروت', genres: ['Rap']),
  Artist(id: 'felukah', name: 'Felukah', nameAr: 'فلوكة', genres: ['Rap', 'R&B']),
  Artist(id: 'mohammed-ramadan', name: 'Mohamed Ramadan', nameAr: 'محمد رمضان', genres: ['Pop', 'Rap']),

  // — Indie / Rock —
  Artist(id: 'cairokee', name: 'Cairokee', nameAr: 'كايروكي', genres: ['Rock', 'Indie']),
  Artist(id: 'massar-egbari', name: 'Massar Egbari', nameAr: 'مسار إجباري', genres: ['Rock', 'Indie']),
  Artist(id: 'sharmoofers', name: 'Sharmoofers', nameAr: 'شارموفرز', genres: ['Indie', 'Pop']),
  Artist(id: 'hamza-namira', name: 'Hamza Namira', nameAr: 'حمزة نمرة', genres: ['Indie', 'Pop']),
  Artist(id: 'mashrou-leila', name: 'Mashrou\' Leila', nameAr: 'مشروع ليلى', genres: ['Indie', 'Rock']),
  Artist(id: 'yasmine-hamdan', name: 'Yasmine Hamdan', nameAr: 'ياسمين حمدان', genres: ['Indie']),
  Artist(id: 'elyanna', name: 'Elyanna', nameAr: 'إليانا', genres: ['Pop', 'Alternative']),
];
