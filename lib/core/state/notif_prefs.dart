import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local_prefs.dart';
import '../services/firebase/user_sync.dart';

/// Notification preferences, persisted locally and mirrored to
/// `users/{uid}.notifPrefs` so the ingestion runner honors them when fanning
/// out pushes (master switch, muted cities, quiet hours).
@immutable
class NotifPrefs {
  const NotifPrefs({
    this.enabled = true,
    this.mutedCities = const {},
    this.quietStart,
    this.quietEnd,
  });

  final bool enabled;
  final Set<String> mutedCities;

  /// Quiet-hours window in local hours [0–23]; null when disabled.
  final int? quietStart;
  final int? quietEnd;

  bool get quietHoursOn => quietStart != null && quietEnd != null;

  NotifPrefs copyWith({
    bool? enabled,
    Set<String>? mutedCities,
    int? quietStart,
    int? quietEnd,
    bool clearQuiet = false,
  }) =>
      NotifPrefs(
        enabled: enabled ?? this.enabled,
        mutedCities: mutedCities ?? this.mutedCities,
        quietStart: clearQuiet ? null : (quietStart ?? this.quietStart),
        quietEnd: clearQuiet ? null : (quietEnd ?? this.quietEnd),
      );

  /// Shape written to Firestore (read by `notify.ts`).
  Map<String, dynamic> toMap() => {
        'enabled': enabled,
        'mutedCities': mutedCities.toList(),
        'quietStart': quietStart,
        'quietEnd': quietEnd,
      };
}

class NotifPrefsNotifier extends Notifier<NotifPrefs> {
  @override
  NotifPrefs build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final qs = prefs.getInt(PrefKeys.notifQuietStart);
    final qe = prefs.getInt(PrefKeys.notifQuietEnd);
    return NotifPrefs(
      enabled: prefs.getBool(PrefKeys.notifEnabled) ?? true,
      mutedCities:
          (prefs.getStringList(PrefKeys.notifMutedCities) ?? const []).toSet(),
      quietStart: qs == null || qs < 0 ? null : qs,
      quietEnd: qe == null || qe < 0 ? null : qe,
    );
  }

  void setEnabled(bool value) => _update(state.copyWith(enabled: value));

  void toggleMutedCity(String cityId) {
    final next = Set<String>.from(state.mutedCities);
    if (!next.add(cityId)) next.remove(cityId);
    _update(state.copyWith(mutedCities: next));
  }

  void setQuietHours(int? start, int? end) => _update(
        start == null || end == null
            ? state.copyWith(clearQuiet: true)
            : state.copyWith(quietStart: start, quietEnd: end),
      );

  void _update(NotifPrefs next) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(PrefKeys.notifEnabled, next.enabled);
    prefs.setStringList(PrefKeys.notifMutedCities, next.mutedCities.toList());
    prefs.setInt(PrefKeys.notifQuietStart, next.quietStart ?? -1);
    prefs.setInt(PrefKeys.notifQuietEnd, next.quietEnd ?? -1);
    state = next;
    UserSync.instance.setNotifPrefs(next.toMap());
  }
}

final notifPrefsProvider =
    NotifierProvider<NotifPrefsNotifier, NotifPrefs>(NotifPrefsNotifier.new);
