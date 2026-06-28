import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/app_settings.dart';
import '../../core/widgets/artist_avatar.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/artist_repository.dart';
import '../../data/event_repository.dart';
import '../../l10n/app_localizations.dart';
import '../event/widgets/event_card.dart';
import 'widgets/follow_button.dart';

class ArtistDetailScreen extends ConsumerWidget {
  const ArtistDetailScreen({super.key, required this.artistId});

  final String artistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(appSettingsProvider).locale.languageCode;
    final artist = ref.watch(artistByIdProvider(artistId));

    if (artist == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(icon: Icons.person_off_outlined, message: '—'),
      );
    }

    final text = Theme.of(context).textTheme;
    final events = ref.watch(eventRepositoryProvider).forArtist(artist.id);
    return Scaffold(
      appBar: AppBar(title: Text(artist.displayName(lang))),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          Center(child: ArtistAvatar(artist: artist, radius: 56)),
          const SizedBox(height: 16),
          Center(
            child: Text(
              artist.displayName(lang),
              style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          if (artist.genres.isNotEmpty) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(artist.genres.join(' · '), style: text.bodyMedium),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(24),
            child: FollowButton(artistId: artist.id),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.eventUpcoming,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          if (events.isEmpty)
            EmptyState(icon: Icons.event_outlined, message: l10n.discoverEmpty)
          else
            for (final event in events) EventCard(event: event),
        ],
      ),
    );
  }
}
