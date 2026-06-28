import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/event.dart';

/// Localized, colour-coded status pill for an event.
class EventStatusChip extends StatelessWidget {
  const EventStatusChip({super.key, required this.status});

  final EventStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final (String label, Color bg, Color fg) = switch (status) {
      EventStatus.onsale => (l10n.eventOnSale, scheme.primaryContainer, scheme.onPrimaryContainer),
      EventStatus.announced => (l10n.eventAnnounced, scheme.secondaryContainer, scheme.onSecondaryContainer),
      EventStatus.soldout => (l10n.eventSoldOut, scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
      EventStatus.cancelled => (l10n.eventCancelled, scheme.errorContainer, scheme.onErrorContainer),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
