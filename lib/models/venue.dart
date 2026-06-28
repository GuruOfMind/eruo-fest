import 'package:flutter/foundation.dart';

/// A physical venue where events take place.
@immutable
class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    this.lat,
    this.lng,
    this.sourceIds = const {},
  });

  final String id;
  final String name;
  final String city;
  final String country;
  final double? lat;
  final double? lng;
  final Map<String, String> sourceIds;

  factory Venue.fromMap(String id, Map<String, dynamic> map) => Venue(
        id: id,
        name: map['name'] as String? ?? '',
        city: map['city'] as String? ?? '',
        country: map['country'] as String? ?? '',
        lat: (map['lat'] as num?)?.toDouble(),
        lng: (map['lng'] as num?)?.toDouble(),
        sourceIds:
            (map['sourceIds'] as Map?)?.cast<String, String>() ?? const {},
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'city': city,
        'country': country,
        'lat': lat,
        'lng': lng,
        'sourceIds': sourceIds,
      };
}
