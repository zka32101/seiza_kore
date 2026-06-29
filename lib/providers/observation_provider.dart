import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/observation.dart';

class ObservationNotifier extends StateNotifier<List<Observation>> {
  static const _key = 'observations';

  ObservationNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr != null) {
      try {
        final list = jsonDecode(jsonStr) as List;
        state = list
            .map((e) => Observation.fromJson(e as Map<String, dynamic>))
            .toList();
        return;
      } catch (_) {
        // 破損データは無視してサンプルを使う
      }
    }
    state = _sampleData;
  }

  Future<void> addObservation(Observation obs) async {
    state = [obs, ...state];
    await _save();
  }

  Future<void> deleteObservation(String id) async {
    state = state.where((o) => o.id != id).toList();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(state.map((o) => o.toJson()).toList()),
    );
  }
}

final observationListProvider =
    StateNotifierProvider<ObservationNotifier, List<Observation>>(
  (ref) => ObservationNotifier(),
);

// サンプルデータ（初回のみ）
final _sampleData = [
  Observation(
    id: 'obs_001',
    constellationId: 'orion',
    timestamp: DateTime(2026, 6, 20, 22, 30),
    locationName: '東京都新宿区',
    latitude: 35.6895,
    longitude: 139.6917,
    bortleScale: 9,
    weather: '晴れ',
    notes: '今年最高の観測！ベテルギウスがよく見えた',
    photoUrls: [],
  ),
  Observation(
    id: 'obs_002',
    constellationId: 'gemini',
    timestamp: DateTime(2026, 6, 15, 21, 0),
    locationName: '神奈川県横浜市',
    latitude: 35.4437,
    longitude: 139.638,
    bortleScale: 8,
    weather: '薄曇り',
    notes: 'カストルとポルックスが美しかった',
    photoUrls: [],
  ),
  Observation(
    id: 'obs_003',
    constellationId: 'leo',
    timestamp: DateTime(2026, 5, 10, 22, 0),
    locationName: '長野県諏訪市',
    latitude: 36.038,
    longitude: 138.073,
    bortleScale: 3,
    weather: '快晴',
    notes: '暗い空でレグルスが輝いていた！都市では見えない細かい星まで見えた',
    photoUrls: [],
  ),
];

final observationFilterProvider = StateProvider<String>((ref) => 'all');

final filteredObservationsProvider = Provider<List<Observation>>((ref) {
  final all = ref.watch(observationListProvider);
  final filter = ref.watch(observationFilterProvider);
  if (filter == 'all') return all;
  return all.where((o) => o.constellationId == filter).toList();
});
