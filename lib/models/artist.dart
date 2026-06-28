import 'package:flutter/foundation.dart';

/// A performing artist in the catalog. EuroFest centres on MENA artists,
/// so we keep both a Latin [name] and an Arabic [nameAr].
@immutable
class Artist {
  const Artist({
    required this.id,
    required this.name,
    this.nameAr,
    this.aliases = const [],
    this.genres = const [],
    this.category = 'music',
    this.imageUrl,
    this.sourceIds = const {},
    this.isMENA = true,
    this.followerCount = 0,
  });

  final String id;
  final String name;
  final String? nameAr;
  final List<String> aliases;
  final List<String> genres;

  /// Catalog segment: 'music' or 'comedy' (stand-up). Drives which source
  /// classification we search and lets the UI group acts.
  final String category;
  final String? imageUrl;

  /// External identifiers keyed by source, e.g.
  /// `{ "ticketmaster": "K8vZ...", "bandsintown": "12345" }`.
  final Map<String, String> sourceIds;
  final bool isMENA;
  final int followerCount;

  /// Localised display name for the given [languageCode].
  String displayName(String languageCode) =>
      (languageCode == 'ar' && nameAr != null && nameAr!.isNotEmpty)
          ? nameAr!
          : name;

  factory Artist.fromMap(String id, Map<String, dynamic> map) => Artist(
        id: id,
        name: map['name'] as String? ?? '',
        nameAr: map['nameAr'] as String?,
        aliases: (map['aliases'] as List?)?.cast<String>() ?? const [],
        genres: (map['genres'] as List?)?.cast<String>() ?? const [],
        category: map['category'] as String? ?? 'music',
        imageUrl: map['imageUrl'] as String?,
        sourceIds:
            (map['sourceIds'] as Map?)?.cast<String, String>() ?? const {},
        isMENA: map['isMENA'] as bool? ?? true,
        followerCount: (map['followerCount'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'nameAr': nameAr,
        'aliases': aliases,
        'genres': genres,
        'category': category,
        'imageUrl': imageUrl,
        'sourceIds': sourceIds,
        'isMENA': isMENA,
        'followerCount': followerCount,
      };
}
