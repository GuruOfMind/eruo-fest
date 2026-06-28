import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/empty_state.dart';
import '../../data/artist_repository.dart';
import '../../data/follows_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/artist.dart';
import '../artist/widgets/artist_tile.dart';

class MyArtistsScreen extends ConsumerWidget {
  const MyArtistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(artistRepositoryProvider);
    final followed = ref
        .watch(followsProvider)
        .map(repo.byId)
        .whereType<Artist>()
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myArtistsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.myArtistsBrowseCta,
            onPressed: () => context.go('/artists/browse'),
          ),
        ],
      ),
      body: followed.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 0,
                    child: EmptyState(
                      icon: Icons.favorite_outline,
                      message: l10n.myArtistsEmpty,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => context.go('/artists/browse'),
                    icon: const Icon(Icons.search),
                    label: Text(l10n.myArtistsBrowseCta),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: followed.length,
              itemBuilder: (_, i) => ArtistTile(artist: followed[i]),
            ),
    );
  }
}
