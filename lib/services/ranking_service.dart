import 'dart:math';
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

/// フレンド/クラス限定のグループコード単位で観測数を競うランキングを
/// 提供するサービス。
///
/// 匿名認証を含むFirebase Authenticationのユーザーを対象に、
/// Firestoreの `users` コレクションを `groupCode` で絞り込み、
/// `totalObservations` 降順で取得する。不特定多数が参加するグローバル
/// 公開ランキングは、低年齢層への社会的比較圧力やCOPPA/AADC上のリスクが
/// あるため廃止し、コードを知っている人同士だけが参加できる設計にした。
///
/// このコレクションはランキング画面を開いたタイミングで、端末のローカル
/// 記録をもとに書き込み（同期）される。
///
/// NOTE: `groupCode`による絞り込みと`totalObservations`による並び替えを
/// 組み合わせるため、Firestoreコンソールで以下の複合インデックスの作成が
/// 別途必要（`users`コレクション: `groupCode` 昇順 + `totalObservations` 降順）。
class RankingService {
  const RankingService._();

  static const _usersCollection = 'users';
  static const _groupCodeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  /// サインインしていなければ匿名サインインし、現在のFirebaseユーザーを返す。
  static Future<User> ensureSignedIn() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) return auth.currentUser!;
    final result = await auth.signInAnonymously();
    return result.user!;
  }

  /// 紛らわしい文字（0/O, 1/I）を除いた6文字のグループコードを生成する。
  static String generateGroupCode() {
    final rand = Random();
    return List.generate(
      6,
      (_) => _groupCodeChars[rand.nextInt(_groupCodeChars.length)],
    ).join();
  }

  /// 端末のローカル統計をFirestoreの自分のユーザードキュメントに反映する。
  static Future<void> syncMyStats({
    required String uid,
    String? displayName,
    required int totalObservations,
    required int unlockedConstellations,
    required String groupCode,
  }) async {
    final doc = FirebaseFirestore.instance.collection(_usersCollection).doc(uid);
    await doc.set({
      if (displayName != null && displayName.isNotEmpty)
        'displayName': displayName,
      'totalObservations': totalObservations,
      'unlockedConstellations': unlockedConstellations,
      'groupCode': groupCode,
      'lastSyncedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// 指定グループコード内で、観測数の多い順にトップNのランキングを取得する。
  static Future<List<RankingEntry>> fetchTopByObservations({
    required String groupCode,
    int limit = 20,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(_usersCollection)
        .where('groupCode', isEqualTo: groupCode)
        .orderBy('totalObservations', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map(RankingEntry.fromDoc).toList();
  }
}
