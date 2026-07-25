import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/timecapsule_event.dart';

class TimecapsuleRecordNotifier
    extends StateNotifier<List<TimecapsuleRecord>> {
  TimecapsuleRecordNotifier() : super([]) {
    _load();
  }

  static const _key = 'timecapsule_records';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List;
        state = list
            .map((e) => TimecapsuleRecord.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        state = [];
      }
    }
  }

  Future<void> addRecord(TimecapsuleRecord record) async {
    state = [...state, record];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(state.map((r) => r.toJson()).toList()),
    );
  }
}

final timecapsuleRecordListProvider =
    StateNotifierProvider<TimecapsuleRecordNotifier, List<TimecapsuleRecord>>(
  (ref) => TimecapsuleRecordNotifier(),
);

final timecapsuleEventsProvider =
    Provider<List<TimecapsuleEvent>>((ref) => _events2026);

// 2026年のイベントマスターデータ
final _events2026 = [
  TimecapsuleEvent(
    id: 'shubunkiza_2026',
    name: 'しぶんぎ座流星群',
    type: TimecapsuleEventType.meteor,
    openTime: DateTime(2026, 1, 3, 21, 0),
    closeTime: DateTime(2026, 1, 5, 6, 0),
    description: '毎年1月初旬に活動するしぶんぎ座流星群。ピーク時には1時間に最大110個の流星が観測できる三大流星群の一つ。2026年は月明かりが少なく好条件。',
    emoji: '⭐',
  ),
  TimecapsuleEvent(
    id: 'lyrid_2026',
    name: '4月こと座流星群',
    type: TimecapsuleEventType.meteor,
    openTime: DateTime(2026, 4, 22, 21, 0),
    closeTime: DateTime(2026, 4, 23, 6, 0),
    description: '4月下旬に活動すること座流星群。ハレー彗星とは別の彗星（サッチャー彗星）のダストが起源。ベガの近くから流れ星が飛び出してくる。',
    emoji: '🎵',
  ),
  TimecapsuleEvent(
    id: 'perseid_2026',
    name: 'ペルセウス座流星群',
    type: TimecapsuleEventType.meteor,
    openTime: DateTime(2026, 8, 12, 20, 0),
    closeTime: DateTime(2026, 8, 13, 6, 0),
    description: '夏の夜を彩るペルセウス座流星群。スイフト・タットル彗星を起源とし、ピーク時には1時間に100個以上の流星が降り注ぐ。夏休み中に起こるため観測しやすい。',
    emoji: '⚔️',
  ),
  TimecapsuleEvent(
    id: 'geminid_2026',
    name: 'ふたご座流星群',
    type: TimecapsuleEventType.meteor,
    openTime: DateTime(2026, 12, 13, 20, 0),
    closeTime: DateTime(2026, 12, 14, 23, 59),
    description: '年間最大規模の流星群。小惑星ファエトンを起源とする珍しい流星群で、ピーク時には1時間に最大150個の流星が観測できる。2026年は好条件での観測が期待される。',
    emoji: '♊',
  ),
  TimecapsuleEvent(
    id: 'lunar_eclipse_2026',
    name: '皆既月食',
    type: TimecapsuleEventType.eclipse,
    openTime: DateTime(2026, 8, 28, 18, 30),
    closeTime: DateTime(2026, 8, 28, 22, 30),
    description: '皆既月食が起こる特別な夜。月が地球の影に完全に入り込み、赤銅色の「ブラッドムーン」が現れる幻想的な天文現象。ゆっくりと色が変わっていく様子を観察しよう。',
    emoji: '🌕',
  ),
];

final activeEventsProvider = Provider<List<TimecapsuleEvent>>((ref) {
  final events = ref.watch(timecapsuleEventsProvider);
  return events.where((e) => e.isActive).toList();
});

final upcomingEventsProvider = Provider<List<TimecapsuleEvent>>((ref) {
  final events = ref.watch(timecapsuleEventsProvider);
  return events.where((e) => e.isUpcoming).toList();
});

final pastEventsProvider = Provider<List<TimecapsuleEvent>>((ref) {
  final events = ref.watch(timecapsuleEventsProvider);
  return events.where((e) => e.isPast).toList();
});
