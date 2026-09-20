import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ランキング1件分のエントリ
class RankingEntry {
  final String uid;
  final String displayName;
  final int totalObservations;
  final int unlockedConstellations;

  const RankingEntry({
    required this.uid,
    required this.displayName,
    required this.totalObservations,
    required this.unlockedConstellations,
  });

  factory RankingEntry.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final rawName = data['displayName'] as String?;
    return RankingEntry(
      uid: doc.id,
      displayName: (rawName == null || rawName.isEmpty)
          ? '星空観測者#${doc.id.substring(0, 6)}'
          : rawName,
      totalObservations: data['totalObservations'] as int? ?? 0,
      unlockedConstellations: data['unlockedConstellations'] as int? ?? 0,
    );
  }
}

/// 全ユーザーの観測数を集計したグローバルランキングを提供するサービス。
///
/// 匿名認証を含むFirebase Authenticationのユーザーを対象に、
/// Firestoreの `users` コレクションを `totalObservations` 降順で取得する。
/// このコレクションはランキング画面を開いたタイミングで、端末のローカル
/// 記録をもとに書き込み（同期）される。
class RankingService {
  const RankingService._();

  static const _usersCollection = 'users';

  /// サインインしていなければ匿名サインインし、現在のFirebaseユーザーを返す。
  static Future<User> ensureSignedIn() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) return auth.currentUser!;
    final result = await auth.signInAnonymously();
    return result.user!;
  }

  /// 端末のローカル統計をFirestoreの自分のユーザードキュメントに反映する。
  static Future<void> syncMyStats({
    required String uid,
    String? displayName,
    required int totalObservations,
    required int unlockedConstellations,
  }) async {
    final doc = FirebaseFirestore.instance.collection(_usersCollection).doc(uid);
    await doc.set({
      if (displayName != null && displayName.isNotEmpty)
        'displayName': displayName,
      'totalObservations': totalObservations,
      'unlockedConstellations': unlockedConstellations,
      'lastSyncedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// 観測数の多い順にトップNのランキングを取得する。
  static Future<List<RankingEntry>> fetchTopByObservations({int limit = 20}) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(_usersCollection)
        .orderBy('totalObservations', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map(RankingEntry.fromDoc).toList();
  }
}
