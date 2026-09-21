import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 自由研究レポートの「まとめ・感想」欄。端末に保存され、レポート共有時に含まれる。
class ResearchNoteNotifier extends StateNotifier<String> {
  static const _key = 'research_report_note';

  ResearchNoteNotifier() : super('') {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key) ?? '';
  }

  Future<void> update(String note) async {
    state = note;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, note);
  }
}

final researchReportNoteProvider =
    StateNotifierProvider<ResearchNoteNotifier, String>(
  (ref) => ResearchNoteNotifier(),
);
