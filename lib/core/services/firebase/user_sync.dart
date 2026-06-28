import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_service.dart';

/// Mirrors device-local state (profile, follows, FCM tokens, notification
/// prefs) into the user's Firestore document so the ingestion/notification
/// runner can match events to followers and push to their devices.
///
/// Every method is a no-op when Firebase is unavailable (offline / tests), so
/// callers can fire-and-forget without guarding. `shared_preferences` remains
/// the source of truth for the UI; Firestore is the server-readable mirror.
class UserSync {
  UserSync._();
  static final UserSync instance = UserSync._();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = FirebaseService.uid;
    if (!FirebaseService.isAvailable || uid == null) return null;
    return _db.collection('users').doc(uid);
  }

  /// Upsert profile fields (locale, home city) onto `users/{uid}`.
  Future<void> setProfile({String? locale, String? homeCity}) async {
    final doc = _userDoc;
    if (doc == null) return;
    final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
    if (locale != null) data['locale'] = locale;
    if (homeCity != null) data['homeCity'] = homeCity;
    await doc.set(data, SetOptions(merge: true));
  }

  /// Register this device's FCM token (deduped via arrayUnion).
  Future<void> addFcmToken(String token) async {
    final doc = _userDoc;
    if (doc == null) return;
    await doc.set(
      {'fcmTokens': FieldValue.arrayUnion([token])},
      SetOptions(merge: true),
    );
  }

  /// Persist notification preferences (muted cities, quiet hours, master switch).
  Future<void> setNotifPrefs(Map<String, dynamic> prefs) async {
    final doc = _userDoc;
    if (doc == null) return;
    await doc.set({'notifPrefs': prefs}, SetOptions(merge: true));
  }

  /// Add/remove a single follow under `users/{uid}/follows/{artistId}`.
  Future<void> setFollow(String artistId, bool following,
      {bool notify = true}) async {
    final doc = _userDoc;
    if (doc == null) return;
    final ref = doc.collection('follows').doc(artistId);
    if (following) {
      await ref.set(
        {'followedAt': FieldValue.serverTimestamp(), 'notify': notify},
        SetOptions(merge: true),
      );
    } else {
      await ref.delete();
    }
  }

  /// Batch-write a set of follows (used by onboarding's "follow all selected").
  Future<void> addFollows(Iterable<String> artistIds) async {
    final doc = _userDoc;
    if (doc == null) return;
    final batch = _db.batch();
    for (final id in artistIds) {
      batch.set(
        doc.collection('follows').doc(id),
        {'followedAt': FieldValue.serverTimestamp(), 'notify': true},
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }
}
