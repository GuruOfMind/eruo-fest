import 'package:flutter/foundation.dart';

/// The signed-in user's profile document (`users/{uid}`).
@immutable
class AppUser {
  const AppUser({
    required this.uid,
    this.locale = 'ar',
    this.homeCity,
    this.cities = const [],
    this.fcmTokens = const [],
    this.notifEnabled = true,
  });

  final String uid;
  final String locale;
  final String? homeCity;
  final List<String> cities;
  final List<String> fcmTokens;
  final bool notifEnabled;

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) => AppUser(
        uid: uid,
        locale: map['locale'] as String? ?? 'ar',
        homeCity: map['homeCity'] as String?,
        cities: (map['cities'] as List?)?.cast<String>() ?? const [],
        fcmTokens: (map['fcmTokens'] as List?)?.cast<String>() ?? const [],
        notifEnabled: map['notifEnabled'] as bool? ?? true,
      );

  Map<String, dynamic> toMap() => {
        'locale': locale,
        'homeCity': homeCity,
        'cities': cities,
        'fcmTokens': fcmTokens,
        'notifEnabled': notifEnabled,
      };
}
