import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/state/app_settings.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    final isArabic = settings.locale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.settingsLanguage),
            subtitle: Text(isArabic ? l10n.languageArabic : l10n.languageEnglish),
            trailing: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'ar', label: Text(l10n.languageArabic)),
                ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
              ],
              selected: {settings.locale.languageCode},
              onSelectionChanged: (s) => notifier.setLocale(Locale(s.first)),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.location_city),
            title: Text(l10n.settingsCity),
            subtitle: Text(settings.homeCity ?? '—'),
            onTap: () {}, // M1: city picker
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(l10n.settingsNotifications),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/notifications'),
          ),
        ],
      ),
    );
  }
}
