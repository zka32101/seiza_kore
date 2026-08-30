import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feedback_item.dart';

// 改善要望・不具合報告はサーバー未接続のため端末内に保存し、
// 送信済み一覧として本人が確認できるようにする（将来的にAPI送信に置き換え予定）。
class FeedbackNotifier extends StateNotifier<List<FeedbackItem>> {
  static const _key = 'feedback_items';

  FeedbackNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return;
    try {
      final list = jsonDecode(jsonStr) as List;
      state = list
          .map((e) => FeedbackItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // 破損データは無視する
    }
  }

  Future<void> submit({
    required FeedbackCategory category,
    required String title,
    required String detail,
  }) async {
    final item = FeedbackItem(
      id: 'fb_${DateTime.now().millisecondsSinceEpoch}',
      category: category,
      title: title,
      detail: detail,
      createdAt: DateTime.now(),
    );
    state = [item, ...state];
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(state.map((f) => f.toJson()).toList()),
    );
  }
}

final feedbackListProvider =
    StateNotifierProvider<FeedbackNotifier, List<FeedbackItem>>(
  (ref) => FeedbackNotifier(),
);
