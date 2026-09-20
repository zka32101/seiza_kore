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
    nameEn: 'Quadrantids Meteor Shower',
    type: TimecapsuleEventType.meteor,
    openTime: DateTime(2026, 1, 3, 21, 0),
    closeTime: DateTime(2026, 1, 5, 6, 0),
    description: '毎年1月初旬に活動するしぶんぎ座流星群。ピーク時には1時間に最大110個の流星が観測できる三大流星群の一つ。2026年は月明かりが少なく好条件。',
    descriptionEn: 'The Quadrantids are active in early January every year. One of the "big three" meteor showers, with up to 110 meteors per hour at its peak. Moonlight will be minimal in 2026, making for great viewing conditions.',
    emoji: '⭐',
  ),
  TimecapsuleEvent(
    id: 'lyrid_2026',
    name: '4月こと座流星群',
    nameEn: 'April Lyrids Meteor Shower',
    type: TimecapsuleEventType.meteor,
    openTime: DateTime(2026, 4, 22, 21, 0),
    closeTime: DateTime(2026, 4, 23, 6, 0),
    description: '4月下旬に活動すること座流星群。ハレー彗星とは別の彗星（サッチャー彗星）のダストが起源。ベガの近くから流れ星が飛び出してくる。',
    descriptionEn: 'The Lyrids are active in late April. They originate from the dust trail of Comet Thatcher, a different comet from Halley\'s. Meteors appear to radiate from near the star Vega.',
    emoji: '🎵',
  ),
  TimecapsuleEvent(
    id: 'perseid_2026',
    name: 'ペルセウス座流星群',
    nameEn: 'Perseids Meteor Shower',
    type: TimecapsuleEventType.meteor,
    openTime: DateTime(2026, 8, 12, 20, 0),
    closeTime: DateTime(2026, 8, 13, 6, 0),
    description: '夏の夜を彩るペルセウス座流星群。スイフト・タットル彗星を起源とし、ピーク時には1時間に100個以上の流星が降り注ぐ。夏休み中に起こるため観測しやすい。',
    descriptionEn: 'The Perseids light up summer nights. They originate from Comet Swift-Tuttle, with more than 100 meteors per hour at their peak. Falling during summer vacation, they\'re easy to observe.',
    emoji: '⚔️',
  ),
  TimecapsuleEvent(
    id: 'geminid_2026',
    name: 'ふたご座流星群',
    nameEn: 'Geminids Meteor Shower',
    type: TimecapsuleEventType.meteor,
    openTime: DateTime(2026, 12, 13, 20, 0),
    closeTime: DateTime(2026, 12, 14, 23, 59),
    description: '年間最大規模の流星群。小惑星ファエトンを起源とする珍しい流星群で、ピーク時には1時間に最大150個の流星が観測できる。2026年は好条件での観測が期待される。',
    descriptionEn: 'The largest meteor shower of the year. An unusual shower that originates from the asteroid Phaethon, with up to 150 meteors per hour at its peak. Good viewing conditions are expected in 2026.',
    emoji: '♊',
  ),
  TimecapsuleEvent(
    id: 'lunar_eclipse_2026',
    name: '皆既月食',
    nameEn: 'Total Lunar Eclipse',
    type: TimecapsuleEventType.eclipse,
    openTime: DateTime(2026, 8, 28, 18, 30),
    closeTime: DateTime(2026, 8, 28, 22, 30),
    description: '皆既月食が起こる特別な夜。月が地球の影に完全に入り込み、赤銅色の「ブラッドムーン」が現れる幻想的な天文現象。ゆっくりと色が変わっていく様子を観察しよう。',
    descriptionEn: 'A special night with a total lunar eclipse. The Moon passes fully into Earth\'s shadow, creating a mystical reddish "blood moon." Watch how its color slowly changes.',
    emoji: '🌕',
  ),
  TimecapsuleEvent(
    id: 'eta_aquariid_2026',
    name: 'みずがめ座η流星群',
    nameEn: 'Eta Aquariids Meteor Shower',
    type: TimecapsuleEventType.meteor,
    openTime: DateTime(2026, 5, 5, 3, 0),
    closeTime: DateTime(2026, 5, 6, 4, 30),
    description: 'ハレー彗星のちりを起源とする流星群。ピークは明け方に近づくほど好条件になり、1時間に数十個の流星が期待できる。南の空低くから流れることが多いので、見晴らしの良い場所がおすすめ。',
    descriptionEn: 'A meteor shower that originates from the dust of Halley\'s Comet. Conditions improve closer to dawn, with dozens of meteors per hour expected. They often streak low across the southern sky, so an open view of the horizon helps.',
    emoji: '☄️',
  ),
  TimecapsuleEvent(
    id: 'orionid_2026',
    name: 'オリオン座流星群',
    nameEn: 'Orionids Meteor Shower',
    type: TimecapsuleEventType.meteor,
    openTime: DateTime(2026, 10, 21, 22, 0),
    closeTime: DateTime(2026, 10, 22, 5, 0),
    description: 'こちらもハレー彗星が起源。オリオン座の頭の近くを放射点として、1時間に10〜20個ほどの流星が見られる。冬の入り口、澄んだ夜空での観測に向いている。',
    descriptionEn: 'Also originating from Halley\'s Comet. Meteors radiate from near the head of Orion, with 10-20 per hour visible. Best observed under clear skies as winter approaches.',
    emoji: '🏹',
  ),
  TimecapsuleEvent(
    id: 'leonid_2026',
    name: 'しし座流星群',
    nameEn: 'Leonids Meteor Shower',
    type: TimecapsuleEventType.meteor,
    openTime: DateTime(2026, 11, 17, 23, 0),
    closeTime: DateTime(2026, 11, 18, 5, 30),
    description: 'かつて「流星雨」として1時間に数千個も出現した記録を持つ流星群。テンペル・タットル彗星を起源とし、普段は控えめだが速く明るい流星が多い。真夜中過ぎが観測のねらい目。',
    descriptionEn: 'A shower once famous for "meteor storms" of thousands per hour. It originates from Comet Tempel-Tuttle; usually modest, but with many fast, bright meteors. Best viewed after midnight.',
    emoji: '🦁',
  ),
  TimecapsuleEvent(
    id: 'jupiter_opposition_2026',
    name: '木星が見頃（衝）',
    nameEn: 'Jupiter at Opposition',
    type: TimecapsuleEventType.conjunction,
    openTime: DateTime(2026, 1, 10, 18, 0),
    closeTime: DateTime(2026, 2, 10, 23, 59),
    description: '木星が地球から見て太陽の反対側にくる「衝」の時期。一晩中観測でき、地球との距離も近くなるため一年で最も明るく大きく見える。双眼鏡でもガリレオ衛星（4つの月）が見えることがある。',
    descriptionEn: 'The time when Jupiter is positioned opposite the Sun as seen from Earth ("opposition"). Visible all night and closest to Earth, making it appear its biggest and brightest of the year. Even binoculars can sometimes reveal the Galilean moons (its four largest moons).',
    emoji: '🪐',
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
