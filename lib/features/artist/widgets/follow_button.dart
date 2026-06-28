import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/follows_repository.dart';
import '../../../l10n/app_localizations.dart';

/// Toggles follow state for [artistId]. Filled when following, outlined when not.
class FollowButton extends ConsumerWidget {
  const FollowButton({super.key, required this.artistId, this.compact = false});

  final String artistId;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final following = ref.watch(isFollowingProvider(artistId));
    void onTap() => ref.read(followsProvider.notifier).toggle(artistId);

    if (compact) {
      return IconButton(
        onPressed: onTap,
        isSelected: following,
        icon: const Icon(Icons.favorite_outline),
        selectedIcon: const Icon(Icons.favorite),
        tooltip: following ? l10n.following : l10n.follow,
      );
    }

    final label = Text(following ? l10n.following : l10n.follow);
    final icon = Icon(following ? Icons.favorite : Icons.favorite_outline);
    return following
        ? OutlinedButton.icon(onPressed: onTap, icon: icon, label: label)
        : FilledButton.icon(onPressed: onTap, icon: icon, label: label);
  }
}
