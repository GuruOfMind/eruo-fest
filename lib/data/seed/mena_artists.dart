import '../../models/artist.dart';

/// Curated launch catalog of MENA artists who tour (or could tour) Europe.
///
/// This is a hand-seeded starting set for M1. In M2+ the catalog is backed by
/// the `artists` Firestore collection and enriched with real `sourceIds`
/// (ticketmaster / bandsintown) used by the ingestion pipeline.
const List<Artist> kMenaArtistsSeed = [
  Artist(id: 'amr-diab', name: 'Amr Diab', nameAr: 'عمرو دياب', genres: ['Pop']),
  Artist(id: 'elissa', name: 'Elissa', nameAr: 'إليسا', genres: ['Pop']),
  Artist(id: 'nancy-ajram', name: 'Nancy Ajram', nameAr: 'نانسي عجرم', genres: ['Pop']),
  Artist(id: 'tamer-hosny', name: 'Tamer Hosny', nameAr: 'تامر حسني', genres: ['Pop']),
  Artist(id: 'mohammed-hamaki', name: 'Mohamed Hamaki', nameAr: 'محمد حماقي', genres: ['Pop']),
  Artist(id: 'assala', name: 'Assala Nasri', nameAr: 'أصالة نصري', genres: ['Tarab']),
  Artist(id: 'kazem-al-saher', name: 'Kazem Al Saher', nameAr: 'كاظم الساهر', genres: ['Tarab']),
  Artist(id: 'sherine', name: 'Sherine', nameAr: 'شيرين', genres: ['Pop']),
  Artist(id: 'myriam-fares', name: 'Myriam Fares', nameAr: 'ميريام فارس', genres: ['Pop']),
  Artist(id: 'balqees', name: 'Balqees', nameAr: 'بلقيس', genres: ['Khaleeji', 'Pop']),
  Artist(id: 'saint-levant', name: 'Saint Levant', nameAr: 'سان ليفان', genres: ['Hip-Hop', 'R&B']),
  Artist(id: 'marwan-pablo', name: 'Marwan Pablo', nameAr: 'مروان بابلو', genres: ['Rap', 'Trap']),
  Artist(id: 'wegz', name: 'Wegz', nameAr: 'ويجز', genres: ['Rap', 'Mahraganat']),
  Artist(id: 'cairokee', name: 'Cairokee', nameAr: 'كايروكي', genres: ['Rock', 'Indie']),
  Artist(id: 'massar-egbari', name: 'Massar Egbari', nameAr: 'مسار إجباري', genres: ['Rock', 'Indie']),
  Artist(id: 'sharmoofers', name: 'Sharmoofers', nameAr: 'شارموفرز', genres: ['Indie', 'Pop']),
  Artist(id: 'mohammed-ramadan', name: 'Mohamed Ramadan', nameAr: 'محمد رمضان', genres: ['Pop', 'Rap']),
  Artist(id: 'carmen-soliman', name: 'Carmen Soliman', nameAr: 'كارمن سليمان', genres: ['Pop']),
];
