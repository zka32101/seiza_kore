import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/constellation.dart';

final constellationListProvider =
    FutureProvider<List<Constellation>>((ref) async {
  final jsonStr = await rootBundle.loadString('assets/data/constellations.json');
  final List<dynamic> data = json.decode(jsonStr) as List<dynamic>;
  return data
      .map((e) => Constellation.fromJson(e as Map<String, dynamic>))
      .toList();
});

// --- 解放済み星座 ---
class UnlockedIdsNotifier extends StateNotifier<Set<String>> {
  static const _key = 'unlocked_ids';
  static const _defaults = {
    'aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo',
    'libra', 'scorpius', 'sagittarius', 'capricornus', 'aquarius', 'pisces',
  };

  UnlockedIdsNotifier() : super(_defaults) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key);
    if (saved != null && saved.isNotEmpty) {
      state = {..._defaults, ...saved.toSet()};
    }
  }

  Future<void> unlock(String id) async {
    if (state.contains(id)) return;
    state = {...state, id};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state.toList());
  }
}

final unlockedIdsProvider =
    StateNotifierProvider<UnlockedIdsNotifier, Set<String>>(
  (ref) => UnlockedIdsNotifier(),
);

final catalogFilterProvider = StateProvider<String>((ref) => 'all');

final catalogSearchProvider = StateProvider<String>((ref) => '');

// ソート: name / difficulty / season / favorites
final catalogSortProvider = StateProvider<String>((ref) => 'name');

// 難易度フィルタ（1-5）
final catalogMinDifficultyProvider = StateProvider<int>((ref) => 1);
final catalogMaxDifficultyProvider = StateProvider<int>((ref) => 5);

// 可視性フィルタ（current = 今月、all = 通年）
final catalogVisibilityProvider = StateProvider<String>((ref) => 'all');

// 解放状況フィルタ（all = 全て、unlocked = 解放済み、locked = 未解放）
final catalogUnlockedFilterProvider = StateProvider<String>((ref) => 'all');

// --- お気に入り星座ID ---
class FavoriteIdsNotifier extends StateNotifier<Set<String>> {
  static const _key = 'favorite_ids';

  FavoriteIdsNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key);
    if (saved != null) state = saved.toSet();
  }

  void toggle(String id) {
    state = state.contains(id)
        ? state.where((s) => s != id).toSet()
        : {...state, id};
    _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state.toList());
  }
}

final favoriteIdsProvider =
    StateNotifierProvider<FavoriteIdsNotifier, Set<String>>(
  (ref) => FavoriteIdsNotifier(),
);

final filteredConstellationsProvider =
    Provider<AsyncValue<List<Constellation>>>((ref) {
  final allAsync = ref.watch(constellationListProvider);
  final filter = ref.watch(catalogFilterProvider);
  final search = ref.watch(catalogSearchProvider).trim().toLowerCase();
  final sort = ref.watch(catalogSortProvider);
  final minDiff = ref.watch(catalogMinDifficultyProvider);
  final maxDiff = ref.watch(catalogMaxDifficultyProvider);
  final visibility = ref.watch(catalogVisibilityProvider);
  final unlockedFilter = ref.watch(catalogUnlockedFilterProvider);
  final favoriteIds = ref.watch(favoriteIdsProvider);
  final unlockedIds = ref.watch(unlockedIdsProvider);

  return allAsync.when(
    data: (all) {
      var result = filter == 'all'
          ? all.toList()
          : filter == 'favorites'
              ? all.where((c) => favoriteIds.contains(c.id)).toList()
              : all.where((c) => c.category == filter).toList();

      if (search.isNotEmpty) {
        result = result.where((c) {
          return c.nameJa.toLowerCase().contains(search) ||
              c.nameEn.toLowerCase().contains(search) ||
              c.nameShort.toLowerCase().contains(search);
        }).toList();
      }

      // 難易度フィルタ
      result = result.where((c) {
        return c.baseDifficulty >= minDiff && c.baseDifficulty <= maxDiff;
      }).toList();

      // 可視性フィルタ（今月 or 通年）
      if (visibility == 'current') {
        final month = DateTime.now().month;
        result = result.where((c) {
          return _isInSeason(c.peakMonths, month);
        }).toList();
      }

      // 解放状況フィルタ
      if (unlockedFilter == 'unlocked') {
        result = result.where((c) => unlockedIds.contains(c.id)).toList();
      } else if (unlockedFilter == 'locked') {
        result = result.where((c) => !unlockedIds.contains(c.id)).toList();
      }

      // ソート適用
      switch (sort) {
        case 'difficulty':
          result.sort((a, b) => a.baseDifficulty.compareTo(b.baseDifficulty));
        case 'difficulty_desc':
          result.sort((a, b) => b.baseDifficulty.compareTo(a.baseDifficulty));
        case 'name':
        default:
          // JSONの順（黄道→北天→南天）を維持
          break;
      }

      return AsyncValue.data(result);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

// 今月見頃の星座を推薦（peakMonths から判定）
final recommendedConstellationProvider =
    Provider<AsyncValue<Constellation?>>((ref) {
  final allAsync = ref.watch(constellationListProvider);
  final month = DateTime.now().month;

  return allAsync.when(
    data: (all) {
      // 「X月〜Y月」「X月〜Y月」形式から現在月が見頃かを判定
      final candidates = all.where((c) {
        return _isInSeason(c.peakMonths, month);
      }).toList();
      if (candidates.isEmpty) return const AsyncValue.data(null);
      // 明るい（baseDifficulty低い）星座を優先
      candidates.sort((a, b) => a.baseDifficulty.compareTo(b.baseDifficulty));
      return AsyncValue.data(candidates.first);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

bool _isInSeason(String peakMonths, int currentMonth) {
  // 「通年」はいつでも対象
  if (peakMonths.contains('通年')) return true;
  // 数字を全部抽出して月のリストを作る
  final nums = RegExp(r'\d+').allMatches(peakMonths).map((m) => int.parse(m.group(0)!)).toList();
  if (nums.isEmpty) return false;
  // 範囲を対でチェック (例: 12月〜3月 → 12,3)
  for (int i = 0; i < nums.length - 1; i += 2) {
    final start = nums[i];
    final end = nums[i + 1];
    if (start <= end) {
      if (currentMonth >= start && currentMonth <= end) return true;
    } else {
      // 年をまたぐ (例: 12月〜3月)
      if (currentMonth >= start || currentMonth <= end) return true;
    }
  }
  return false;
}

final constellationByIdProvider =
    Provider.family<AsyncValue<Constellation?>, String>((ref, id) {
  final allAsync = ref.watch(constellationListProvider);
  return allAsync.when(
    data: (all) {
      try {
        return AsyncValue.data(all.firstWhere((c) => c.id == id));
      } catch (_) {
        return const AsyncValue.data(null);
      }
    },
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});
