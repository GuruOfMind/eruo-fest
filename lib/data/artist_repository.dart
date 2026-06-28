import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/artist.dart';
import 'seed/mena_artists.dart';

/// Read access to the artist catalog.
///
/// M1 serves the in-memory [kMenaArtistsSeed]. In M2 swap the implementation
/// for a Firestore-backed one (query the `artists` collection) — callers depend
/// only on this interface, so screens won't change.
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

final artistRepositoryProvider = Provider<ArtistRepository>(
  (ref) => const ArtistRepository(kMenaArtistsSeed),
);

/// Convenience: look up a single artist by id.
final artistByIdProvider = Provider.family<Artist?, String>(
  (ref, id) => ref.watch(artistRepositoryProvider).byId(id),
);
