import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/firebase/user_sync.dart';
import 'local_prefs.dart';

/// The set of artist ids the user follows, persisted locally.
///
/// In a later milestone this becomes the `users/{uid}/follows` subcollection in
/// Firestore (one doc per artist), which is also what the notification
/// fan-out reads. The screen-facing API (watch the set, toggle) stays the same.
class FollowsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return (prefs.getStringList(PrefKeys.follows) ?? const []).toSet();
  }

  bool isFollowing(String artistId) => state.contains(artistId);

  void toggle(String artistId) {
    final next = Set<String>.from(state);
    final following = next.add(artistId);
    if (!following) next.remove(artistId);
    _persist(next);
    // Mirror to Firestore so the notification runner sees the follow.
    UserSync.instance.setFollow(artistId, following);
  }

  void followAll(Iterable<String> artistIds) {
    _persist({...state, ...artistIds});
    UserSync.instance.addFollows(artistIds);
  }

  void _persist(Set<String> next) {
    ref.read(sharedPreferencesProvider).setStringList(
          PrefKeys.follows,
          next.toList(),
        );
    state = next;
  }
}

final followsProvider =
    NotifierProvider<FollowsNotifier, Set<String>>(FollowsNotifier.new);

/// Whether a specific artist is followed (rebuilds only on that artist's change).
final isFollowingProvider = Provider.family<bool, String>(
  (ref, artistId) => ref.watch(followsProvider).contains(artistId),
);
