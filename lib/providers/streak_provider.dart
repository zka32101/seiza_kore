import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'observation_provider.dart';

class StreakState {
  final int freezeCount;
  final Set<DateTime> frozenDates;
  final int lastMilestoneGranted;

  const StreakState({
    this.freezeCount = 0,
    this.frozenDates = const {},
    this.lastMilestoneGranted = 0,
  });

  StreakState copyWith({
    int? freezeCount,
    Set<DateTime>? frozenDates,
    int? lastMilestoneGranted,
  }) {
    return StreakState(
      freezeCount: freezeCount ?? this.freezeCount,
      frozenDates: frozenDates ?? this.frozenDates,
      lastMilestoneGranted: lastMilestoneGranted ?? this.lastMilestoneGranted,
    );
  }
}

/// ストリーク（連続観測日数）のフリーズ機能を管理する。
/// 7日連続観測するごとにフリーズを1個付与（最大3個まで）。
/// フリーズを使うと、その日観測しなくてもストリークが途切れない。
class StreakNotifier extends StateNotifier<StreakState> {
  static const _keyFreezeCount = 'streak_freeze_count';
  static const _keyFrozenDates = 'streak_frozen_dates';
  static const _keyLastMilestone = 'streak_last_milestone';
  static const maxFreezes = 3;

  StreakNotifier() : super(const StreakState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final freezeCount = prefs.getInt(_keyFreezeCount) ?? 0;
    final lastMilestone = prefs.getInt(_keyLastMilestone) ?? 0;
    final frozenList = prefs.getStringList(_keyFrozenDates) ?? [];
    final frozenDates = frozenList.map((s) => DateTime.parse(s)).toSet();
    state = StreakState(
      freezeCount: freezeCount,
      frozenDates: frozenDates,
      lastMilestoneGranted: lastMilestone,
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFreezeCount, state.freezeCount);
    await prefs.setInt(_keyLastMilestone, state.lastMilestoneGranted);
    await prefs.setStringList(
      _keyFrozenDates,
      state.frozenDates.map((d) => d.toIso8601String()).toList(),
    );
  }

  Future<void> maybeGrantFreeze(int currentStreak) async {
    if (state.freezeCount >= maxFreezes) return;
    final milestone = (currentStreak ~/ 7) * 7;
    if (milestone > 0 && milestone > state.lastMilestoneGranted) {
      state = state.copyWith(
        freezeCount: (state.freezeCount + 1).clamp(0, maxFreezes),
        lastMilestoneGranted: milestone,
      );
      await _save();
    }
  }

  Future<bool> useFreezeForDate(DateTime date) async {
    if (state.freezeCount <= 0) return false;
    final day = DateTime(date.year, date.month, date.day);
    if (state.frozenDates.contains(day)) return true;
    state = state.copyWith(
      freezeCount: state.freezeCount - 1,
      frozenDates: {...state.frozenDates, day},
    );
    await _save();
    return true;
  }
}

final streakProvider = StateNotifierProvider<StreakNotifier, StreakState>(
  (ref) => StreakNotifier(),
);

/// フリーズを考慮した連続観測日数。
final protectedStreakProvider = Provider<int>((ref) {
  final observations = ref.watch(observationListProvider);
  final frozenDates = ref.watch(streakProvider).frozenDates;
  if (observations.isEmpty && frozenDates.isEmpty) return 0;

  final days = observations
      .map((o) => DateTime(o.timestamp.year, o.timestamp.month, o.timestamp.day))
      .toSet();

  final today = DateTime.now();
  var cursor = DateTime(today.year, today.month, today.day);
  if (!days.contains(cursor) && !frozenDates.contains(cursor)) {
    cursor = cursor.subtract(const Duration(days: 1));
  }

  var streak = 0;
  while (days.contains(cursor) || frozenDates.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
});

/// 昨日・今日ともに観測がなく、フリーズが残っている場合にのみ、
/// 「ストリークを守る」提案を表示してよいかどうか。
final canUseFreezeTodayProvider = Provider<bool>((ref) {
  final freezeCount = ref.watch(streakProvider).freezeCount;
  if (freezeCount <= 0) return false;

  final observations = ref.watch(observationListProvider);
  final today = DateTime.now();
  final todayDay = DateTime(today.year, today.month, today.day);
  final yesterday = todayDay.subtract(const Duration(days: 1));

  final days = observations
      .map((o) => DateTime(o.timestamp.year, o.timestamp.month, o.timestamp.day))
      .toSet();
  final frozenDates = ref.watch(streakProvider).frozenDates;

  return !days.contains(todayDay) &&
      !days.contains(yesterday) &&
      !frozenDates.contains(yesterday) &&
      days.isNotEmpty;
});
