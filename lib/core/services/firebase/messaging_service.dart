import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'firebase_service.dart';
import 'user_sync.dart';

/// Background/terminated message handler. Must be a top-level, entry-point
/// function. The inbox doc is written server-side and the OS renders the
/// notification, so there is nothing to do here.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

/// FCM wiring: permission, token registration (mirrored to `users/{uid}`), and
/// routing notification taps to the relevant event. Every entry point no-ops
/// when Firebase is unavailable (offline / tests).
class MessagingService {
  MessagingService._();
  static final MessagingService instance = MessagingService._();

  FirebaseMessaging get _fm => FirebaseMessaging.instance;

  /// Requests permission and registers this device's token, keeping it fresh.
  Future<void> start() async {
    if (!FirebaseService.isAvailable) return;
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await _fm.requestPermission();
      final token = await _fm.getToken();
      if (token != null) await UserSync.instance.addFcmToken(token);
      _fm.onTokenRefresh.listen(UserSync.instance.addFcmToken);
    } catch (e) {
      if (kDebugMode) debugPrint('Messaging start failed: $e');
    }
  }

  /// Routes notification taps (foreground-resumed and cold-start) to the event
  /// carried in the message's `eventId` data field.
  Future<void> wireOpenHandlers(void Function(String eventId) onOpenEvent) async {
    if (!FirebaseService.isAvailable) return;
    void handle(RemoteMessage? m) {
      final id = m?.data['eventId'];
      if (id is String && id.isNotEmpty) onOpenEvent(id);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(handle);
    handle(await _fm.getInitialMessage());
  }
}
