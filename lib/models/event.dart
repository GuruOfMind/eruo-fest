import 'package:flutter/foundation.dart';

/// Lifecycle state of an event, mirrored from the ingestion sources.
enum EventStatus { announced, onsale, soldout, cancelled }

EventStatus _statusFromString(String? value) => switch (value) {
      'onsale' => EventStatus.onsale,
      'soldout' => EventStatus.soldout,
      'cancelled' => EventStatus.cancelled,
      _ => EventStatus.announced,
    };

/// A canonical, normalized event. Multiple raw events from different sources
/// that share a [dedupeKey] are merged into one of these.
@immutable
class Event {
  const Event({
    required this.id,
    required this.artistIds,
    required this.venueId,
    this.venueName,
    required this.city,
    required this.country,
    required this.startsAt,
    required this.status,
    this.ticketUrl,
    this.priceFrom,
    this.currency,
    this.sources = const [],
    required this.dedupeKey,
    this.announcedAt,
  });

  final String id;
  final List<String> artistIds;
  final String venueId;

  /// Denormalized venue name carried on the event doc (the ingestion pipeline
  /// writes it), so the app can show a place without a separate venue lookup.
  final String? venueName;
  final String city;
  final String country;
  final DateTime startsAt;
  final EventStatus status;

  /// Affiliate-wrapped ticket URL (tracking params injected server-side).
  final String? ticketUrl;
  final num? priceFrom;
  final String? currency;
  final List<String> sources;
  final String dedupeKey;
  final DateTime? announcedAt;

  factory Event.fromMap(String id, Map<String, dynamic> map) => Event(
        id: id,
        artistIds: (map['artistIds'] as List?)?.cast<String>() ?? const [],
        venueId: map['venueId'] as String? ?? '',
        venueName: map['venueName'] as String?,
        city: map['city'] as String? ?? '',
        country: map['country'] as String? ?? '',
        startsAt: _toDate(map['startsAt']) ?? DateTime.now(),
        status: _statusFromString(map['status'] as String?),
        ticketUrl: map['ticketUrl'] as String?,
        priceFrom: map['priceFrom'] as num?,
        currency: map['currency'] as String?,
        sources: (map['sources'] as List?)?.cast<String>() ?? const [],
        dedupeKey: map['dedupeKey'] as String? ?? '',
        announcedAt: _toDate(map['announcedAt']),
      );

  Map<String, dynamic> toMap() => {
        'artistIds': artistIds,
        'venueId': venueId,
        'venueName': venueName,
        'city': city,
        'country': country,
        'startsAt': startsAt.toIso8601String(),
        'status': status.name,
        'ticketUrl': ticketUrl,
        'priceFrom': priceFrom,
        'currency': currency,
        'sources': sources,
        'dedupeKey': dedupeKey,
        'announcedAt': announcedAt?.toIso8601String(),
      };

  /// Accepts ISO-8601 strings or Firestore Timestamp-like objects (which
  /// expose a `toDate()` method) without importing cloud_firestore here.
  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }
}
