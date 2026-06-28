import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/state/app_settings.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/artist_repository.dart';
import '../../data/notifications_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/app_notification.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(appSettingsProvider).locale.languageCode;
    final async = ref.watch(notificationsProvider);
    final items = async.asData?.value ?? const <AppNotification>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          if (items.any((n) => !n.read))
            TextButton(
              onPressed: () => ref
                  .read(notificationsRepositoryProvider)
                  .markAllRead(items.map((n) => n.id)),
              child: Text(l10n.notificationsMarkAllRead),
            ),
        ],
      ),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.notifications_none,
              message: l10n.notificationsEmpty,
            )
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) =>
                  _NotificationTile(notification: items[i], lang: lang),
            ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification, required this.lang});

  final AppNotification notification;
  final String lang;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final artistRepo = ref.watch(artistRepositoryProvider);

    final artistLine = notification.artistIds
        .map((id) => artistRepo.byId(id)?.displayName(lang) ?? id)
        .join(lang == 'ar' ? '، ' : ', ');
    final date = DateFormat.yMMMd(lang).add_jm().format(notification.createdAt);
    final subtitle = [l10n.notificationNewEvent, date].join(' · ');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            notification.read ? scheme.surfaceContainerHighest : scheme.primary,
        foregroundColor:
            notification.read ? scheme.onSurfaceVariant : scheme.onPrimary,
        child: const Icon(Icons.music_note),
      ),
      title: Text(
        artistLine,
        style: TextStyle(
          fontWeight: notification.read ? FontWeight.w400 : FontWeight.w700,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: notification.read
          ? null
          : Icon(Icons.circle, size: 10, color: scheme.primary),
      onTap: () {
        ref.read(notificationsRepositoryProvider).markRead(notification.id);
        if (notification.eventId.isNotEmpty) {
          context.push('/event/${notification.eventId}');
        }
      },
    );
  }
}
