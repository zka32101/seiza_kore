import 'package:cloud_firestore/cloud_firestore.dart';

/// 観測中のグループメンバー1件分の状態。
class CoObserver {
  final String uid;
  final String displayName;
  final String? constellationId;
  final DateTime startedAt;

  const CoObserver({
    required this.uid,
    required this.displayName,
    required this.constellationId,
    required this.startedAt,
  });

  factory CoObserver.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final rawName = data['displayName'] as String?;
    final startedAt = data['observingStartedAt'] as Timestamp?;
    return CoObserver(
      uid: doc.id,
      displayName: (rawName == null || rawName.isEmpty)
          ? '星空観測者#${doc.id.substring(0, 6)}'
          : rawName,
      constellationId: data['observingConstellationId'] as String?,
      startedAt: startedAt?.toDate() ?? DateTime.now(),
    );
  }
}

/// フレンド/クラス限定のグループコード内で、今観測中のメンバーを
/// リアルタイムに共有する機能を提供するサービス。
///
/// 具体的な緯度経度などの位置情報は一切共有せず、「今観測中かどうか」と
/// 「観測対象の星座」のみを共有することで、児童向けアプリとしての
/// 安全性（COPPA/AADC配慮）を保っている。ランキング機能と同じ
/// `users`コレクション・`groupCode`を再利用する。
///
/// NOTE: `groupCode`と`isObserving`の両方による絞り込みは、Firestoreの
/// 自動インデックス結合で通常は追加設定なしに動作するが、エラーが出た
/// 場合はFirestoreコンソールの案内に従って複合インデックスを作成する。
class CoObservationService {
  const CoObservationService._();

  static const _usersCollection = 'users';

  /// 観測開始/終了状態を自分のユーザードキュメントに反映する。
  static Future<void> setObserving({
    required String uid,
    required bool isObserving,
    String? constellationId,
  }) async {
    final doc = FirebaseFirestore.instance.collection(_usersCollection).doc(uid);
    await doc.set({
      'isObserving': isObserving,
      'observingConstellationId': isObserving ? constellationId : null,
      'observingStartedAt': isObserving ? FieldValue.serverTimestamp() : null,
    }, SetOptions(merge: true));
  }

  /// 指定グループコード内で、現在観測中のメンバーをリアルタイム監視する。
  /// 開始から[staleAfter]以上経過した記録（アプリ終了等で終了処理が
  /// 呼ばれなかったもの）は呼び出し側で除外すること。
  static Stream<List<CoObserver>> watchGroupObservers({
    required String groupCode,
    String? excludeUid,
  }) {
    return FirebaseFirestore.instance
        .collection(_usersCollection)
        .where('groupCode', isEqualTo: groupCode)
        .where('isObserving', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((doc) => doc.id != excludeUid)
            .map(CoObserver.fromDoc)
            .toList());
  }
}
