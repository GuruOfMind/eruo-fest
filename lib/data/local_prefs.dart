import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the [SharedPreferences] instance. Overridden in `main()` with the
/// resolved instance so the rest of the app can read it synchronously.
///
/// This is the local persistence layer for M1 (onboarding flag, locale, home
/// city, follows). Once Firebase Auth is wired, follows/profile move to
/// `users/{uid}` in Firestore and this stays only for device-local prefs.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  ),
);

/// Preference keys, kept in one place to avoid typos.
abstract final class PrefKeys {
  static const locale = 'locale';
  static const homeCity = 'homeCity';
  static const onboardingComplete = 'onboardingComplete';
  static const follows = 'follows';
  static const notifEnabled = 'notifEnabled';
  static const notifMutedCities = 'notifMutedCities';
  static const notifQuietStart = 'notifQuietStart';
  static const notifQuietEnd = 'notifQuietEnd';
}
