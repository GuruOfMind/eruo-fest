import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/firebase/firebase_service.dart';
import '../../core/state/app_settings.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/event_repository.dart';
import '../../data/seed/european_cities.dart';
import '../../l10n/app_localizations.dart';
import '../../models/event.dart';
import '../event/widgets/event_card.dart';

/// Filter for the discovery feed: true = home city only, false = everywhere.
class _HomeOnlyNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void toggle() => state = !state;
}

final _cityFilterProvider =
    NotifierProvider<_HomeOnlyNotifier, bool>(_HomeOnlyNotifier.new);

class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(appSettingsProvider).locale.languageCode;
    final homeCity = ref.watch(appSettingsProvider).homeCity;
    final homeOnly = ref.watch(_cityFilterProvider) && homeCity != null;

    // Drive loading/error state off the live events stream; the repository
    // reads the same data for filtering.
    final eventsAsync = ref.watch(eventsProvider);
    final events =
        ref.watch(eventRepositoryProvider).upcoming(city: homeOnly ? homeCity : null);

    final cityName = homeCity == null
        ? null
        : kEuropeanCities
            .where((c) => c.id == homeCity)
            .map((c) => c.displayName(lang))
            .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          homeOnly && cityName != null
              ? l10n.discoverNearCity(cityName)
              : l10n.discoverTitle,
        ),
        actions: [
          if (homeCity != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: TextButton(
                onPressed: () => ref.read(_cityFilterProvider.notifier).toggle(),
                child: Text(homeOnly ? l10n.discoverAllCities : cityName ?? ''),
              ),
            ),
        ],
      ),
      body: eventsAsync.when(
        // Only a true network load shows a spinner; offline resolves instantly
        // to seed data, so this never blocks the offline/test experience.
        loading: () => FirebaseService.isAvailable
            ? const Center(child: CircularProgressIndicator())
            : _list(events, l10n),
        error: (_, _) =>
            EmptyState(icon: Icons.cloud_off_outlined, message: l10n.discoverError),
        data: (_) => _list(events, l10n),
      ),
    );
  }

  Widget _list(List<Event> events, AppLocalizations l10n) {
    if (events.isEmpty) {
      return EmptyState(icon: Icons.event_outlined, message: l10n.discoverEmpty);
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: events.length,
      itemBuilder: (_, i) => EventCard(event: events[i]),
    );
  }
}
