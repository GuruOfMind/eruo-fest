import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/state/app_settings.dart';
import '../../../data/artist_repository.dart';
import '../../../data/event_repository.dart';
import '../../../models/event.dart';
import 'event_status_chip.dart';

/// Compact card summarising an event: artist line, date, venue/city, status.
/// Tapping opens the event detail screen.
class EventCard extends ConsumerWidget {
  const EventCard({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appSettingsProvider).locale.languageCode;
    final artistRepo = ref.watch(artistRepositoryProvider);
    final venue = ref.watch(eventRepositoryProvider).venue(event.venueId);
    final text = Theme.of(context).textTheme;

    final artistLine = event.artistIds
        .map((id) => artistRepo.byId(id)?.displayName(lang) ?? id)
        .join('، ');
    final dateLine = DateFormat.yMMMMEEEEd(lang).add_jm().format(event.startsAt);
    final venueLine = [venue?.name, event.country].whereType<String>().join(' · ');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => context.push('/event/${event.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      artistLine,
                      style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  EventStatusChip(status: event.status),
                ],
              ),
              const SizedBox(height: 8),
              _IconLine(icon: Icons.calendar_today_outlined, text: dateLine),
              const SizedBox(height: 4),
              _IconLine(icon: Icons.place_outlined, text: venueLine),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: scheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
