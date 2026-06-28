import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/firebase/firebase_service.dart';
import '../models/artist.dart';
import 'seed/mena_artists.dart';

/// Read access to the artist catalog.
///
/// Backed by the live `artists` Firestore collection when Firebase is available
/// (see [artistsProvider]) so the catalog can grow server-side without an app
/// update; falls back to [kMenaArtistsSeed] while loading or offline.
class ArtistRepository {
  const ArtistRepository(this._artists);

  final List<Artist> _artists;

  List<Artist> all() => List.unmodifiable(_artists);

  Artist? byId(String id) {
    for (final a in _artists) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// Case-insensitive search across Latin name, Arabic name, and aliases.
  List<Artist> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all();
    return _artists.where((a) {
      bool hit(String? s) => s != null && s.toLowerCase().contains(q);
      return hit(a.name) ||
          hit(a.nameAr) ||
          a.aliases.any((alias) => alias.toLowerCase().contains(q)) ||
          a.genres.any((g) => g.toLowerCase().contains(q));
    }).toList();
  }
}

/// Live catalog stream. From Firestore (`artists`, ordered by `name`) when
/// Firebase is wired; otherwise a one-shot of the local seed so the app is
/// fully runnable offline and in tests.
final artistsProvider = StreamProvider<List<Artist>>((ref) {
  if (!FirebaseService.isAvailable) {
    return Stream.value(kMenaArtistsSeed);
  }
  return FirebaseFirestore.instance
      .collection('artists')
      .orderBy('name')
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => Artist.fromMap(d.id, d.data())).toList());
});

final artistRepositoryProvider = Provider<ArtistRepository>((ref) {
  // Seed while the Firestore stream loads, then the live catalog once it lands.
  final artists = ref.watch(artistsProvider).asData?.value ?? kMenaArtistsSeed;
  return ArtistRepository(artists);
});

/// Convenience: look up a single artist by id.
final artistByIdProvider = Provider.family<Artist?, String>(
  (ref, id) => ref.watch(artistRepositoryProvider).byId(id),
);
