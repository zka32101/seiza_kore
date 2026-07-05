import 'package:cloud_firestore/cloud_firestore.dart';

/// User profile in Firestore
class FirestoreUser {
  final String uid;
  final String? email;
  final String? displayName;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isAnonymous;
  final int totalObservations;
  final int unlockedConstellations;

  const FirestoreUser({
    required this.uid,
    this.email,
    this.displayName,
    required this.createdAt,
    required this.lastLoginAt,
    required this.isAnonymous,
    required this.totalObservations,
    required this.unlockedConstellations,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'isAnonymous': isAnonymous,
      'totalObservations': totalObservations,
      'unlockedConstellations': unlockedConstellations,
    };
  }

  /// Create from Firestore document
  factory FirestoreUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirestoreUser(
      uid: doc.id,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
      isAnonymous: data['isAnonymous'] as bool? ?? true,
      totalObservations: data['totalObservations'] as int? ?? 0,
      unlockedConstellations: data['unlockedConstellations'] as int? ?? 0,
    );
  }

  /// Copy with
  FirestoreUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isAnonymous,
    int? totalObservations,
    int? unlockedConstellations,
  }) {
    return FirestoreUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      totalObservations: totalObservations ?? this.totalObservations,
      unlockedConstellations: unlockedConstellations ?? this.unlockedConstellations,
    );
  }
}

/// Observation record stored in Firestore
class FirestoreObservation {
  final String id;
  final String uid;
  final String constellationId;
  final DateTime timestamp;
  final String locationName;
  final int bortleScale;
  final String weather;
  final String notes;
  final int difficultyStars;
  final DateTime createdAt;

  const FirestoreObservation({
    required this.id,
    required this.uid,
    required this.constellationId,
    required this.timestamp,
    required this.locationName,
    required this.bortleScale,
    required this.weather,
    required this.notes,
    required this.difficultyStars,
    required this.createdAt,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'constellationId': constellationId,
      'timestamp': Timestamp.fromDate(timestamp),
      'locationName': locationName,
      'bortleScale': bortleScale,
      'weather': weather,
      'notes': notes,
      'difficultyStars': difficultyStars,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create from Firestore document
  factory FirestoreObservation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirestoreObservation(
      id: doc.id,
      uid: data['uid'] as String,
      constellationId: data['constellationId'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      locationName: data['locationName'] as String? ?? '不明',
      bortleScale: data['bortleScale'] as int? ?? 5,
      weather: data['weather'] as String? ?? '不明',
      notes: data['notes'] as String? ?? '',
      difficultyStars: data['difficultyStars'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}

/// Firestore collection paths
class FirestorePaths {
  static const String users = 'users';
  static const String observations = 'observations';
  static const String achievements = 'achievements';

  /// Get observations subcollection path for user
  static String userObservations(String uid) => '$users/$uid/$observations';

  /// Get achievements subcollection path for user
  static String userAchievements(String uid) => '$users/$uid/$achievements';
}
