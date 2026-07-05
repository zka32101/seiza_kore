import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/constellation_time_capsule.dart';

class ConstellationTimeCapsuleNotifier
    extends StateNotifier<List<ConstellationTimeCapsule>> {
  ConstellationTimeCapsuleNotifier() : super([]) {
    _load();
  }

  static const _key = 'constellation_time_capsules';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List;
        state = list
            .map((e) => ConstellationTimeCapsule.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        // Handle corrupted data
        state = [];
      }
    }
  }

  Future<void> addCapsule(ConstellationTimeCapsule capsule) async {
    state = [...state, capsule];
    await _save();
  }

  Future<void> removeCapsule(String id) async {
    state = state.where((c) => c.id != id).toList();
    await _save();
  }

  Future<void> updateCapsule(ConstellationTimeCapsule capsule) async {
    state = state.map((c) => c.id == capsule.id ? capsule : c).toList();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(state.map((c) => c.toJson()).toList()),
    );
  }
}

/// Constellation Time Capsule list provider
final constellationTimeCapsuleListProvider = StateNotifierProvider<
    ConstellationTimeCapsuleNotifier,
    List<ConstellationTimeCapsule>>((ref) => ConstellationTimeCapsuleNotifier());

/// Active (unlocked) time capsules
final activeConstellationCapsuleProvider =
    Provider<List<ConstellationTimeCapsule>>((ref) {
  final capsules = ref.watch(constellationTimeCapsuleListProvider);
  return capsules.where((c) => c.isUnlocked).toList();
});

/// Upcoming (locked) time capsules
final upcomingConstellationCapsuleProvider =
    Provider<List<ConstellationTimeCapsule>>((ref) {
  final capsules = ref.watch(constellationTimeCapsuleListProvider);
  return capsules.where((c) => !c.isUnlocked).toList();
});

/// Get capsules for specific constellation
final constellationCapsulesByIdProvider =
    Provider.family<List<ConstellationTimeCapsule>, String>((ref, constellationId) {
  final capsules = ref.watch(constellationTimeCapsuleListProvider);
  return capsules.where((c) => c.constellationId == constellationId).toList();
});

/// Statistics
final constellationCapsuleStatsProvider =
    Provider<({int total, int unlocked, int upcoming})>((ref) {
  final capsules = ref.watch(constellationTimeCapsuleListProvider);
  final unlocked = capsules.where((c) => c.isUnlocked).length;
  return (
    total: capsules.length,
    unlocked: unlocked,
    upcoming: capsules.length - unlocked,
  );
});
