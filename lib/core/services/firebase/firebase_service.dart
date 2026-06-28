import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../../firebase_options.dart';

/// Thin wrapper around Firebase initialization + anonymous auth.
///
/// Initializes Firebase with the generated [DefaultFirebaseOptions] and signs
/// the user in anonymously so each device has a stable `uid` for its
/// `users/{uid}` document (profile, follows, notifications).
///
/// Everything still fails **softly**: in unit/widget tests (no native Firebase)
/// or before the project is reachable, [ensureInitialized] swallows the error
/// and leaves [isAvailable] false, so the app (onboarding, navigation, theming,
/// RTL, seed data) stays fully runnable offline.
class FirebaseService {
  FirebaseService._();

  static bool _available = false;
  static String? _uid;

  /// Whether Firebase initialized + authenticated successfully this session.
  static bool get isAvailable => _available;

  /// The anonymous (or linked) user id, when Firebase is available.
  static String? get uid => _uid;

  static Future<void> ensureInitialized() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final auth = FirebaseAuth.instance;
      final cred = auth.currentUser ?? (await auth.signInAnonymously()).user;
      _uid = cred?.uid;
      _available = _uid != null;
    } catch (error, stack) {
      _available = false;
      _uid = null;
      if (kDebugMode) {
        debugPrint(
          'Firebase unavailable — running in offline/seed mode. ($error)',
        );
        debugPrintStack(stackTrace: stack);
      }
    }
  }
}
