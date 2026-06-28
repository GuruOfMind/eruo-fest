import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/firebase/firebase_service.dart';
import '../models/app_notification.dart';

CollectionReference<Map<String, dynamic>>? _inboxRef() {
  final uid = FirebaseService.uid;
  if (!FirebaseService.isAvailable || uid == null) return null;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('notifications');
}

/// Live inbox for the signed-in user, newest first. Empty when Firebase is
/// unavailable (offline / tests).
final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final inbox = _inboxRef();
  if (inbox == null) return Stream.value(const <AppNotification>[]);
  return inbox
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => AppNotification.fromMap(d.id, d.data()))
          .toList());
});

/// Count of unread notifications, for the nav-bar badge.
final unreadCountProvider = Provider<int>((ref) {
  final items = ref.watch(notificationsProvider).asData?.value ?? const [];
  return items.where((n) => !n.read).length;
});

/// Mutations on the inbox (mark read / mark all read). No-ops offline.
class NotificationsRepository {
  Future<void> markRead(String id) async {
    final inbox = _inboxRef();
    if (inbox == null) return;
    await inbox.doc(id).set({'read': true}, SetOptions(merge: true));
  }

  Future<void> markAllRead(Iterable<String> ids) async {
    final inbox = _inboxRef();
    if (inbox == null) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final id in ids) {
      batch.set(inbox.doc(id), {'read': true}, SetOptions(merge: true));
    }
    await batch.commit();
  }
}

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) => NotificationsRepository());
