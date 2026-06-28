import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/app_settings.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/event_repository.dart';
import '../../data/seed/european_cities.dart';
import '../../l10n/app_localizations.dart';
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
      body: events.isEmpty
          ? EmptyState(icon: Icons.event_outlined, message: l10n.discoverEmpty)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: events.length,
              itemBuilder: (_, i) => EventCard(event: events[i]),
            ),
    );
  }
}
