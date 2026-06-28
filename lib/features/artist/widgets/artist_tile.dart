import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/app_settings.dart';
import '../../../core/widgets/artist_avatar.dart';
import '../../../models/artist.dart';
import 'follow_button.dart';

/// List row for an artist: avatar, localized name, genres, and a follow toggle.
/// Tapping the row opens the artist detail screen.
class ArtistTile extends ConsumerWidget {
  const ArtistTile({super.key, required this.artist});

  final Artist artist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appSettingsProvider).locale.languageCode;
    return ListTile(
      leading: ArtistAvatar(artist: artist, radius: 24),
      title: Text(artist.displayName(lang)),
      subtitle: artist.genres.isEmpty ? null : Text(artist.genres.join(' · ')),
      trailing: FollowButton(artistId: artist.id, compact: true),
      onTap: () => context.go('/artists/${artist.id}'),
    );
  }
}
