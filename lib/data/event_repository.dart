import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/firebase/firebase_service.dart';
import '../models/event.dart';
import '../models/venue.dart';
import 'seed/seed_events.dart';
import 'seed/seed_venues.dart';

/// Read access to events and their venues.
///
/// Backed by the live `events` Firestore collection when Firebase is available
/// (see [eventsProvider]); falls back to the local seed while loading or when
/// running offline / in tests. Screens depend only on this API.
class EventRepository {
  EventRepository(this._events, List<Venue> venues)
      : _venues = {for (final v in venues) v.id: v};

  final List<Event> _events;
  final Map<String, Venue> _venues;

  Venue? venue(String id) => _venues[id];

  Event? byId(String id) {
    for (final e in _events) {
      if (e.id == id) return e;
    }
    return null;
  }

  List<Event> _sorted(Iterable<Event> events) {
    final list = events.toList()..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return list;
  }

  /// Upcoming events, optionally filtered to a [city] id. Past events excluded.
  List<Event> upcoming({String? city, DateTime? now}) {
    final from = now ?? DateTime.now();
    return _sorted(_events.where((e) =>
        e.startsAt.isAfter(from) && (city == null || e.city == city)));
  }

  /// Upcoming events featuring [artistId].
  List<Event> forArtist(String artistId, {DateTime? now}) {
    final from = now ?? DateTime.now();
    return _sorted(_events.where((e) =>
        e.artistIds.contains(artistId) && e.startsAt.isAfter(from)));
  }
}

/// Live stream of all events. From Firestore (`events`, ordered by `startsAt`)
/// when Firebase is wired; otherwise a one-shot of the local seed so the app is
/// fully runnable offline and in tests.
final eventsProvider = StreamProvider<List<Event>>((ref) {
  if (!FirebaseService.isAvailable) {
    return Stream.value(kSeedEvents);
  }
  return FirebaseFirestore.instance
      .collection('events')
      .orderBy('startsAt')
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => Event.fromMap(d.id, d.data())).toList());
});

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  // `valueOrNull` yields the seed while the Firestore stream is still loading,
  // then the live events once they arrive — screens stay synchronous.
  final events = ref.watch(eventsProvider).asData?.value ?? kSeedEvents;
  return EventRepository(events, kSeedVenues);
});
