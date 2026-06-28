import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/app_settings.dart';
import '../../core/state/notif_prefs.dart';
import '../../data/seed/european_cities.dart';
import '../../l10n/app_localizations.dart';

class NotifPrefsScreen extends ConsumerWidget {
  const NotifPrefsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(appSettingsProvider).locale.languageCode;
    final prefs = ref.watch(notifPrefsProvider);
    final notifier = ref.read(notifPrefsProvider.notifier);
    final enabled = prefs.enabled;

    String hh(int h) => '${h.toString().padLeft(2, '0')}:00';

    Future<void> pickQuiet() async {
      final start = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: prefs.quietStart ?? 22, minute: 0),
        helpText: l10n.notifPrefsFrom,
      );
      if (start == null || !context.mounted) return;
      final end = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: prefs.quietEnd ?? 8, minute: 0),
        helpText: l10n.notifPrefsTo,
      );
      if (end == null) return;
      notifier.setQuietHours(start.hour, end.hour);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifPrefsTitle)),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: Text(l10n.notifPrefsMaster),
            subtitle: Text(l10n.notifPrefsMasterSub),
            value: enabled,
            onChanged: notifier.setEnabled,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.bedtime_outlined),
            title: Text(l10n.notifPrefsQuietHours),
            subtitle: Text(
              prefs.quietHoursOn
                  ? '${hh(prefs.quietStart!)} – ${hh(prefs.quietEnd!)}'
                  : l10n.notifPrefsQuietHoursSub,
            ),
            value: prefs.quietHoursOn,
            onChanged: enabled
                ? (on) {
                    if (on) {
                      pickQuiet();
                    } else {
                      notifier.setQuietHours(null, null);
                    }
                  }
                : null,
          ),
          if (prefs.quietHoursOn && enabled)
            ListTile(
              leading: const SizedBox(width: 24),
              title: Text(l10n.notifPrefsQuietHours),
              trailing: TextButton(
                onPressed: pickQuiet,
                child: Text('${hh(prefs.quietStart!)} – ${hh(prefs.quietEnd!)}'),
              ),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              l10n.notifPrefsMutedCities,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
            child: Text(
              l10n.notifPrefsMutedCitiesSub,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final c in kEuropeanCities)
                  FilterChip(
                    label: Text(c.displayName(lang)),
                    selected: prefs.mutedCities.contains(c.id),
                    onSelected: enabled
                        ? (_) => notifier.toggleMutedCity(c.id)
                        : null,
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.notifPrefsArtists,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
