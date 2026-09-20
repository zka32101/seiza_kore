import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'observation_provider.dart';
import 'constellation_provider.dart';
import 'timecapsule_provider.dart';

class Achievement {
  final String id;
  final String title;
  final String titleEn;
  final String description;
  final String descriptionEn;
  final String emoji;
  final bool isUnlocked;
  final int progress;
  final int goal;

  const Achievement({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.description,
    required this.descriptionEn,
    required this.emoji,
    required this.isUnlocked,
    required this.progress,
    required this.goal,
  });

  String localizedTitle(String languageCode) => languageCode == 'en' ? titleEn : title;

  String localizedDescription(String languageCode) =>
      languageCode == 'en' ? descriptionEn : description;
}

final achievementsProvider = Provider<List<Achievement>>((ref) {
  final observations = ref.watch(observationListProvider);
  final unlockedIds = ref.watch(unlockedIdsProvider);
  final timecapsuleRecords = ref.watch(timecapsuleRecordListProvider);

  // シティハンター: Bortle 7以上の都市で10回観測
  final cityObs = observations.where((o) => o.bortleScale >= 7).length;

  // ウルトラシティマスター: Bortle 8-9（最高難易度の光害）で20回観測
  final ultraCityObs = observations.where((o) => o.bortleScale >= 8).length;

  // 星読み師: 全88星座を解放
  final totalUnlocked = unlockedIds.length;

  // 時間旅行者: タイムカプセルイベント3回記録
  final capsuleCount = timecapsuleRecords.length;

  // 初観測者: 初めて観測を記録
  final firstObs = observations.length;

  // 精皆勤: 同じ星座を5回観測（リピーター）
  final constellationObsCounts = <String, int>{};
  for (final o in observations) {
    constellationObsCounts[o.constellationId] =
        (constellationObsCounts[o.constellationId] ?? 0) + 1;
  }
  final maxRepeat =
      constellationObsCounts.values.isEmpty ? 0 : constellationObsCounts.values.reduce((a, b) => a > b ? a : b);

  // ダークスカイハンター: Bortle 3以下で観測
  final darkSkyObs = observations.where((o) => o.bortleScale <= 3).length;

  // コレクション系
  final zodiacCount = unlockedIds.where((id) {
    // zodiacのIDは constellation_provider の _defaults と同じ
    const zodiacIds = {
      'aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo',
      'libra', 'scorpius', 'sagittarius', 'capricornus', 'aquarius', 'pisces',
    };
    return zodiacIds.contains(id);
  }).length;

  return [
    Achievement(
      id: 'first_observation',
      title: '初めての観測',
      titleEn: 'First Observation',
      description: '初めて星座を観測した',
      descriptionEn: 'Observed a constellation for the first time',
      emoji: '🌟',
      isUnlocked: firstObs >= 1,
      progress: firstObs.clamp(0, 1),
      goal: 1,
    ),
    Achievement(
      id: 'city_hunter',
      title: 'シティハンター',
      titleEn: 'City Hunter',
      description: '光害の中で10回観測（Bortle 7以上）',
      descriptionEn: 'Observed 10 times under light pollution (Bortle 7+)',
      emoji: '🏙️',
      isUnlocked: cityObs >= 10,
      progress: cityObs.clamp(0, 10),
      goal: 10,
    ),
    Achievement(
      id: 'star_reader',
      title: '星読み師',
      titleEn: 'Star Reader',
      description: '全88星座を図鑑に収めた',
      descriptionEn: 'Collected all 88 constellations',
      emoji: '📚',
      isUnlocked: totalUnlocked >= 88,
      progress: totalUnlocked.clamp(0, 88),
      goal: 88,
    ),
    Achievement(
      id: 'time_traveler',
      title: '時間旅行者',
      titleEn: 'Time Traveler',
      description: 'タイムカプセルイベントを3回記録',
      descriptionEn: 'Recorded 3 time capsule events',
      emoji: '⏳',
      isUnlocked: capsuleCount >= 3,
      progress: capsuleCount.clamp(0, 3),
      goal: 3,
    ),
    Achievement(
      id: 'repeater',
      title: '星の常連',
      titleEn: 'Regular Stargazer',
      description: '同じ星座を5回観測',
      descriptionEn: 'Observed the same constellation 5 times',
      emoji: '🔄',
      isUnlocked: maxRepeat >= 5,
      progress: maxRepeat.clamp(0, 5),
      goal: 5,
    ),
    Achievement(
      id: 'dark_sky',
      title: 'ダークスカイハンター',
      titleEn: 'Dark Sky Hunter',
      description: 'Bortle 3以下の暗い空で観測',
      descriptionEn: 'Observed under dark skies (Bortle 3 or darker)',
      emoji: '🌌',
      isUnlocked: darkSkyObs >= 1,
      progress: darkSkyObs.clamp(0, 1),
      goal: 1,
    ),
    Achievement(
      id: 'zodiac_complete',
      title: '黄道コンプリート',
      titleEn: 'Zodiac Complete',
      description: '黄道12星座をすべて図鑑に登録した',
      descriptionEn: 'Collected all 12 zodiac constellations',
      emoji: '♾️',
      isUnlocked: zodiacCount >= 12,
      progress: zodiacCount.clamp(0, 12),
      goal: 12,
    ),
    Achievement(
      id: 'collector_25',
      title: 'コレクター',
      titleEn: 'Collector',
      description: '25個の星座を図鑑に登録した',
      descriptionEn: 'Collected 25 constellations',
      emoji: '🎖️',
      isUnlocked: totalUnlocked >= 25,
      progress: totalUnlocked.clamp(0, 25),
      goal: 25,
    ),
    Achievement(
      id: 'collector_50',
      title: '大コレクター',
      titleEn: 'Master Collector',
      description: '50個の星座を図鑑に登録した',
      descriptionEn: 'Collected 50 constellations',
      emoji: '🏆',
      isUnlocked: totalUnlocked >= 50,
      progress: totalUnlocked.clamp(0, 50),
      goal: 50,
    ),
    Achievement(
      id: 'ultra_city_master',
      title: 'ウルトラシティマスター',
      titleEn: 'Ultra City Master',
      description: '最極限の光害（Bortle 8-9）で20回観測',
      descriptionEn: 'Observed 20 times under extreme light pollution (Bortle 8-9)',
      emoji: '🌃',
      isUnlocked: ultraCityObs >= 20,
      progress: ultraCityObs.clamp(0, 20),
      goal: 20,
    ),
  ];
});

// ユーザーの称号ID（最上位の解放済みアチーブメント）。表示文言は userTitleLabel() で言語別に取得する。
final userTitleProvider = Provider<String>((ref) {
  final achievements = ref.watch(achievementsProvider);
  final unlocked = achievements.where((a) => a.isUnlocked).toList();

  if (unlocked.any((a) => a.id == 'star_reader')) return 'star_reader';
  if (unlocked.any((a) => a.id == 'ultra_city_master')) return 'ultra_city_master';
  if (unlocked.any((a) => a.id == 'collector_50')) return 'collector_50';
  if (unlocked.any((a) => a.id == 'zodiac_complete')) return 'zodiac_master';
  if (unlocked.any((a) => a.id == 'time_traveler')) return 'time_traveler';
  if (unlocked.any((a) => a.id == 'city_hunter')) return 'city_hunter';
  if (unlocked.any((a) => a.id == 'dark_sky')) return 'dark_sky';
  if (unlocked.any((a) => a.id == 'collector_25')) return 'collector_25';
  if (unlocked.any((a) => a.id == 'repeater')) return 'repeater';
  if (unlocked.any((a) => a.id == 'first_observation')) return 'apprentice';
  return 'beginner';
});

const _userTitleLabelsJa = {
  'star_reader': '星読み師',
  'ultra_city_master': 'ウルトラシティマスター',
  'collector_50': '大コレクター',
  'zodiac_master': '黄道マスター',
  'time_traveler': '時間旅行者',
  'city_hunter': 'シティハンター',
  'dark_sky': 'ダークスカイハンター',
  'collector_25': 'コレクター',
  'repeater': '星の常連',
  'apprentice': '見習い星詠み',
  'beginner': '星初心者',
};

const _userTitleLabelsEn = {
  'star_reader': 'Star Reader',
  'ultra_city_master': 'Ultra City Master',
  'collector_50': 'Master Collector',
  'zodiac_master': 'Zodiac Master',
  'time_traveler': 'Time Traveler',
  'city_hunter': 'City Hunter',
  'dark_sky': 'Dark Sky Hunter',
  'collector_25': 'Collector',
  'repeater': 'Regular Stargazer',
  'apprentice': 'Apprentice Stargazer',
  'beginner': 'Beginner',
};

/// [userTitleProvider]が返す称号IDを、言語コードに応じた表示文言に変換する。
String userTitleLabel(String titleId, String languageCode) {
  final map = languageCode == 'en' ? _userTitleLabelsEn : _userTitleLabelsJa;
  return map[titleId] ?? map['beginner']!;
}

// 解放済みアチーブメント数
final unlockedAchievementCountProvider = Provider<int>((ref) {
  return ref.watch(achievementsProvider).where((a) => a.isUnlocked).length;
});
