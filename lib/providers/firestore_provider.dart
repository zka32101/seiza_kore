import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/firestore_models.dart';

/// Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// User profile provider
final firestoreUserProvider = FutureProvider.family<FirestoreUser?, String>((ref, uid) async {
  final firestore = ref.watch(firestoreProvider);
  final doc = await firestore.collection('users').doc(uid).get();
  if (!doc.exists) return null;
  return FirestoreUser.fromFirestore(doc);
});

/// Save or update user profile
final saveUserProfileProvider = FutureProvider.family<void, FirestoreUser>((ref, user) async {
  final firestore = ref.watch(firestoreProvider);
  await firestore.collection('users').doc(user.uid).set(user.toFirestore(), SetOptions(merge: true));
});

/// Observations list for current user
final userObservationsProvider = StreamProvider.family<List<FirestoreObservation>, String>((ref, uid) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('users')
      .doc(uid)
      .collection('observations')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => FirestoreObservation.fromFirestore(doc)).toList());
});

/// Save observation record
final saveObservationProvider = FutureProvider.family<String, (String, FirestoreObservation)>((ref, data) async {
  final (uid, observation) = data;
  final firestore = ref.watch(firestoreProvider);

  final docRef = await firestore
      .collection('users')
      .doc(uid)
      .collection('observations')
      .add(observation.toFirestore());

  return docRef.id;
});

/// Observations for specific constellation
final constellationObservationsProvider =
    StreamProvider.family<List<FirestoreObservation>, (String, String)>((ref, data) {
  final (uid, constellationId) = data;
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('users')
      .doc(uid)
      .collection('observations')
      .where('constellationId', isEqualTo: constellationId)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => FirestoreObservation.fromFirestore(doc)).toList());
});
