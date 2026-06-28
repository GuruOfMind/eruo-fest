import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/firebase/analytics_service.dart';
import '../../core/state/app_settings.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/artist_repository.dart';
import '../../data/event_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/event.dart';
import 'widgets/event_status_chip.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(appSettingsProvider).locale.languageCode;
    final repo = ref.watch(eventRepositoryProvider);
    final artistRepo = ref.watch(artistRepositoryProvider);
    final event = repo.byId(eventId);

    if (event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(icon: Icons.event_busy_outlined, message: '—'),
      );
    }

    final venueName = event.venueName ?? repo.venue(event.venueId)?.name;
    final text = Theme.of(context).textTheme;
    final artistLine = event.artistIds
        .map((id) => artistRepo.byId(id)?.displayName(lang) ?? id)
        .join('، ');
    final dateLine = DateFormat.yMMMMEEEEd(lang).add_jm().format(event.startsAt);
    final canBook =
        event.ticketUrl != null && event.status != EventStatus.cancelled;

    return Scaffold(
      appBar: AppBar(title: Text(artistLine)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  artistLine,
                  style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              EventStatusChip(status: event.status),
            ],
          ),
          const SizedBox(height: 24),
          _DetailRow(icon: Icons.calendar_today_outlined, value: dateLine),
          if (venueName != null)
            _DetailRow(icon: Icons.place_outlined, value: '$venueName · ${event.country}'),
          if (event.priceFrom != null)
            _DetailRow(
              icon: Icons.confirmation_number_outlined,
              value: l10n.eventFrom(
                NumberFormat.simpleCurrency(name: event.currency).format(event.priceFrom),
              ),
            ),
          _DetailRow(
            icon: Icons.podcasts_outlined,
            value: event.sources.join(' · '),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          12 + MediaQuery.of(context).padding.bottom,
        ),
        child: FilledButton.icon(
          onPressed: canBook ? () => _book(context, event) : null,
          icon: const Icon(Icons.open_in_new),
          label: Text(
            event.status == EventStatus.soldout ? l10n.eventSoldOut : l10n.eventBook,
          ),
        ),
      ),
    );
  }

  // Opens the affiliate-wrapped ticket URL in the external browser/app and logs
  // the click for affiliate attribution.
  Future<void> _book(BuildContext context, Event event) async {
    final messenger = ScaffoldMessenger.of(context);
    AnalyticsService.instance.logBookClick(
      eventId: event.id,
      source: event.sources.isNotEmpty ? event.sources.first : 'unknown',
      city: event.city,
    );
    final ok = await launchUrl(
      Uri.parse(event.ticketUrl!),
      mode: LaunchMode.externalApplication,
    );
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(event.ticketUrl!)));
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.value});
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 16),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
