import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/update_notes_data.dart';

// 最新バージョンの更新内容をまだ見ていない場合に true。
// 設定画面のバッジ表示に使う。
class UpdateSeenNotifier extends StateNotifier<bool> {
  static const _key = 'last_seen_update_version';

  UpdateSeenNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSeen = prefs.getString(_key);
    state = lastSeen != currentAppVersion;
  }

  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, currentAppVersion);
    state = false;
  }
}

final hasUnseenUpdateProvider =
    StateNotifierProvider<UpdateSeenNotifier, bool>(
  (ref) => UpdateSeenNotifier(),
);
