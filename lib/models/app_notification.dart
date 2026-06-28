import 'package:flutter/foundation.dart';

/// An inbox notification written by the ingestion runner under
/// `users/{uid}/notifications`. Mirrors the fields the runner sets in
/// `notify.ts`.
@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.eventId,
    required this.type,
    this.artistIds = const [],
    this.city,
    this.read = false,
    required this.createdAt,
  });

  final String id;
  final String eventId;
  final String type; // e.g. "new_event"
  final List<String> artistIds;
  final String? city;
  final bool read;
  final DateTime createdAt;

  factory AppNotification.fromMap(String id, Map<String, dynamic> map) =>
      AppNotification(
        id: id,
        eventId: map['eventId'] as String? ?? '',
        type: map['type'] as String? ?? 'new_event',
        artistIds: (map['artistIds'] as List?)?.cast<String>() ?? const [],
        city: map['city'] as String?,
        read: map['read'] as bool? ?? false,
        createdAt: _toDate(map['createdAt']) ?? DateTime.now(),
      );

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
