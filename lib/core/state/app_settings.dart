import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local_prefs.dart';
import '../services/firebase/user_sync.dart';

/// User-facing app settings, persisted to [SharedPreferences].
///
/// In a later milestone (once Firebase Auth is wired) these sync to the
/// `users/{uid}` document. The default locale is Arabic — EuroFest is
/// Arabic-first.
@immutable
class AppSettings {
  const AppSettings({
    this.locale = const Locale('ar'),
    this.homeCity,
    this.onboardingComplete = false,
  });

  final Locale locale;
  final String? homeCity;
  final bool onboardingComplete;

  AppSettings copyWith({
    Locale? locale,
    String? homeCity,
    bool? onboardingComplete,
  }) =>
      AppSettings(
        locale: locale ?? this.locale,
        homeCity: homeCity ?? this.homeCity,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      );
}

class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppSettings(
      locale: Locale(prefs.getString(PrefKeys.locale) ?? 'ar'),
      homeCity: prefs.getString(PrefKeys.homeCity),
      onboardingComplete: prefs.getBool(PrefKeys.onboardingComplete) ?? false,
    );
  }

  void setLocale(Locale locale) {
    ref.read(sharedPreferencesProvider).setString(
          PrefKeys.locale,
          locale.languageCode,
        );
    state = state.copyWith(locale: locale);
    UserSync.instance.setProfile(locale: locale.languageCode);
  }

  void toggleLocale() => setLocale(
        state.locale.languageCode == 'ar'
            ? const Locale('en')
            : const Locale('ar'),
      );

  void setHomeCity(String city) {
    ref.read(sharedPreferencesProvider).setString(PrefKeys.homeCity, city);
    state = state.copyWith(homeCity: city);
    UserSync.instance.setProfile(homeCity: city);
  }

  void completeOnboarding() {
    ref.read(sharedPreferencesProvider).setBool(
          PrefKeys.onboardingComplete,
          true,
        );
    state = state.copyWith(onboardingComplete: true);
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);
