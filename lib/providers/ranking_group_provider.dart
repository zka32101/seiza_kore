import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 参加中のランキンググループコード（フレンド/クラス限定ランキング用）。
/// nullの場合はどのグループにも参加していない。
class RankingGroupNotifier extends StateNotifier<String?> {
  static const _key = 'ranking_group_code';

  RankingGroupNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key);
  }

  Future<void> setGroupCode(String? code) async {
    state = code;
    final prefs = await SharedPreferences.getInstance();
    if (code == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, code);
    }
  }
}

final rankingGroupProvider =
    StateNotifierProvider<RankingGroupNotifier, String?>(
  (ref) => RankingGroupNotifier(),
);
