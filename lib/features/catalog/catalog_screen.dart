import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/empty_state.dart';
import '../../data/artist_repository.dart';
import '../../l10n/app_localizations.dart';
import '../artist/widgets/artist_tile.dart';

/// Searchable catalog used to discover and follow more artists.
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final results = ref.watch(artistRepositoryProvider).search(_query);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.catalogTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SearchBar(
              hintText: l10n.searchArtistsHint,
              leading: const Icon(Icons.search),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    message: l10n.searchNoResults,
                  )
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (_, i) => ArtistTile(artist: results[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
