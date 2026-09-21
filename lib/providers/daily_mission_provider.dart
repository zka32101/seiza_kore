import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'observation_provider.dart';

enum DailyMissionType { observe, quiz }

/// 常時2種類の日替わりミッション（観測・クイズ）。
final dailyMissionsProvider = Provider<List<DailyMissionType>>((ref) {
  return const [DailyMissionType.observe, DailyMissionType.quiz];
});

String todayKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

/// 今日クイズに挑戦したかどうかを日付単位で永続化する。
class QuizCompletionNotifier extends StateNotifier<String?> {
  static const _key = 'daily_quiz_completed_date';

  QuizCompletionNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key);
  }

  Future<void> markCompletedToday() async {
    final today = todayKey();
    if (state == today) return;
    state = today;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, today);
  }
}

final quizCompletionProvider =
    StateNotifierProvider<QuizCompletionNotifier, String?>(
  (ref) => QuizCompletionNotifier(),
);

final quizCompletedTodayProvider = Provider<bool>((ref) {
  return ref.watch(quizCompletionProvider) == todayKey();
});

final observedTodayProvider = Provider<bool>((ref) {
  final observations = ref.watch(observationListProvider);
  final now = DateTime.now();
  return observations.any((o) =>
      o.timestamp.year == now.year &&
      o.timestamp.month == now.month &&
      o.timestamp.day == now.day);
});

/// (完了数, ミッション総数)
final dailyMissionProgressProvider = Provider<(int, int)>((ref) {
  final missions = ref.watch(dailyMissionsProvider);
  final observedToday = ref.watch(observedTodayProvider);
  final quizDone = ref.watch(quizCompletedTodayProvider);

  var done = 0;
  for (final m in missions) {
    if (m == DailyMissionType.observe && observedToday) done++;
    if (m == DailyMissionType.quiz && quizDone) done++;
  }
  return (done, missions.length);
});
