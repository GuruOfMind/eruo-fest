import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'firebase_service.dart';

/// Thin analytics wrapper. The affiliate model lives or dies on **book-click
/// attribution**, so that's the key event. Fails soft when Firebase is
/// unavailable (offline / tests).
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;

  /// Logs a tap on an event's affiliate "Book" button.
  Future<void> logBookClick({
    required String eventId,
    required String source,
    String? city,
  }) async {
    if (!FirebaseService.isAvailable) return;
    try {
      await _analytics.logEvent(
        name: 'book_click',
        parameters: {
          'event_id': eventId,
          'source': source,
          'city': ?city,
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('analytics book_click failed: $e');
    }
  }
}
