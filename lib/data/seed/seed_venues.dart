import '../../models/venue.dart';

/// Seed venues referenced by [kSeedEvents]. Replaced by the Firestore `venues`
/// collection (populated by ingestion) once Firebase is wired.
const List<Venue> kSeedVenues = [
  Venue(id: 'columbiahalle-berlin', name: 'Columbiahalle', city: 'berlin', country: 'DE'),
  Venue(id: 'tempodrom-berlin', name: 'Tempodrom', city: 'berlin', country: 'DE'),
  Venue(id: 'le-trianon-paris', name: 'Le Trianon', city: 'paris', country: 'FR'),
  Venue(id: 'olympia-paris', name: 'L\'Olympia', city: 'paris', country: 'FR'),
  Venue(id: 'o2-forum-london', name: 'O2 Forum Kentish Town', city: 'london', country: 'GB'),
  Venue(id: 'paradiso-amsterdam', name: 'Paradiso', city: 'amsterdam', country: 'NL'),
];
