import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/constellation_nickname.dart';

class ConstellationNicknameNotifier
    extends StateNotifier<Map<String, ConstellationNickname>> {
  ConstellationNicknameNotifier() : super({}) {
    _load();
  }

  static const _key = 'constellation_nicknames';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        state = {
          for (final entry in map.entries)
            entry.key: ConstellationNickname.fromJson(entry.value as Map<String, dynamic>)
        };
      } catch (e) {
        state = {};
      }
    }
  }

  Future<void> setNickname(ConstellationNickname nickname) async {
    state = {...state, nickname.constellationId: nickname};
    await _save();
  }

  Future<void> removeNickname(String constellationId) async {
    state = {...state}..remove(constellationId);
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode({
      for (final entry in state.entries) entry.key: entry.value.toJson(),
    });
    await prefs.setString(_key, json);
  }
}

/// All constellation nicknames
final constellationNicknameMapProvider = StateNotifierProvider<
    ConstellationNicknameNotifier,
    Map<String, ConstellationNickname>>((ref) => ConstellationNicknameNotifier());

/// Get nickname for specific constellation
final constellationNicknameProvider = Provider.family<ConstellationNickname?, String>(
  (ref, constellationId) {
    final nicknames = ref.watch(constellationNicknameMapProvider);
    return nicknames[constellationId];
  },
);

/// Count of named constellations
final namedConstellationCountProvider = Provider<int>((ref) {
  final nicknames = ref.watch(constellationNicknameMapProvider);
  return nicknames.length;
});
