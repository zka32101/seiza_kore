import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final bool nightModeEnabled;
  final bool locationSharingEnabled;
  final bool nightSkyConnectEnabled;
  final bool isPremium;
  final bool isGuest;
  final bool timecapsuleNotificationsEnabled;
  final bool unlockedNotificationsEnabled;

  const AppSettings({
    this.nightModeEnabled = false,
    this.locationSharingEnabled = false,
    this.nightSkyConnectEnabled = false,
    this.isPremium = false,
    this.isGuest = true,
    this.timecapsuleNotificationsEnabled = true,
    this.unlockedNotificationsEnabled = true,
  });

  AppSettings copyWith({
    bool? nightModeEnabled,
    bool? locationSharingEnabled,
    bool? nightSkyConnectEnabled,
    bool? isPremium,
    bool? isGuest,
    bool? timecapsuleNotificationsEnabled,
    bool? unlockedNotificationsEnabled,
  }) {
    return AppSettings(
      nightModeEnabled: nightModeEnabled ?? this.nightModeEnabled,
      locationSharingEnabled:
          locationSharingEnabled ?? this.locationSharingEnabled,
      nightSkyConnectEnabled:
          nightSkyConnectEnabled ?? this.nightSkyConnectEnabled,
      isPremium: isPremium ?? this.isPremium,
      isGuest: isGuest ?? this.isGuest,
      timecapsuleNotificationsEnabled:
          timecapsuleNotificationsEnabled ?? this.timecapsuleNotificationsEnabled,
      unlockedNotificationsEnabled:
          unlockedNotificationsEnabled ?? this.unlockedNotificationsEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  static const _keyNightMode = 'night_mode';
  static const _keyLocationSharing = 'location_sharing';
  static const _keyNightSkyConnect = 'night_sky_connect';
  static const _keyTimecapsuleNotif = 'timecapsule_notifications';
  static const _keyUnlockedNotif = 'unlocked_notifications';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      nightModeEnabled: prefs.getBool(_keyNightMode) ?? false,
      locationSharingEnabled: prefs.getBool(_keyLocationSharing) ?? false,
      nightSkyConnectEnabled: prefs.getBool(_keyNightSkyConnect) ?? false,
      timecapsuleNotificationsEnabled:
          prefs.getBool(_keyTimecapsuleNotif) ?? true,
      unlockedNotificationsEnabled:
          prefs.getBool(_keyUnlockedNotif) ?? true,
    );
  }

  Future<void> setNightMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNightMode, value);
    state = state.copyWith(nightModeEnabled: value);
  }

  Future<void> setLocationSharing(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLocationSharing, value);
    state = state.copyWith(locationSharingEnabled: value);
  }

  Future<void> setNightSkyConnect(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNightSkyConnect, value);
    state = state.copyWith(nightSkyConnectEnabled: value);
  }

  Future<void> setTimecapsuleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTimecapsuleNotif, value);
    state = state.copyWith(timecapsuleNotificationsEnabled: value);
  }

  Future<void> setUnlockedNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUnlockedNotif, value);
    state = state.copyWith(unlockedNotificationsEnabled: value);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

final nightModeProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).nightModeEnabled;
});
