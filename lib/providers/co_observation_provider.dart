import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/co_observation_service.dart';
import '../services/ranking_service.dart';
import 'ranking_group_provider.dart';

const coObservingStaleAfter = Duration(minutes: 30);

/// 参加中のグループ内で、今観測中のメンバー一覧（30分以上古い記録は除外）。
/// グループに参加していない場合は空リストを返す。
final coObserversProvider =
    StreamProvider.autoDispose<List<CoObserver>>((ref) async* {
  final groupCode = ref.watch(rankingGroupProvider);
  if (groupCode == null) {
    yield const [];
    return;
  }

  String? myUid;
  try {
    myUid = (await RankingService.ensureSignedIn()).uid;
  } catch (_) {
    // サインインできない場合は自分自身の除外なしで続行する
  }

  yield* CoObservationService.watchGroupObservers(
    groupCode: groupCode,
    excludeUid: myUid,
  ).map((observers) {
    final cutoff = DateTime.now().subtract(coObservingStaleAfter);
    return observers.where((o) => o.startedAt.isAfter(cutoff)).toList();
  });
});

/// グループに参加していれば、観測開始をメンバーに共有する。
/// 未参加・オフライン時は何もしない（ベストエフォート）。
Future<void> startCoObserving(WidgetRef ref, String constellationId) async {
  final groupCode = ref.read(rankingGroupProvider);
  if (groupCode == null) return;
  try {
    final user = await RankingService.ensureSignedIn();
    await CoObservationService.setObserving(
      uid: user.uid,
      isObserving: true,
      constellationId: constellationId,
    );
  } catch (_) {
    // オフライン等は無視（共有機能はベストエフォート）
  }
}

/// 観測終了をメンバーに共有する。未参加・オフライン時は何もしない。
Future<void> stopCoObserving(WidgetRef ref) async {
  final groupCode = ref.read(rankingGroupProvider);
  if (groupCode == null) return;
  try {
    final user = await RankingService.ensureSignedIn();
    await CoObservationService.setObserving(uid: user.uid, isObserving: false);
  } catch (_) {
    // オフライン等は無視（共有機能はベストエフォート）
  }
}
