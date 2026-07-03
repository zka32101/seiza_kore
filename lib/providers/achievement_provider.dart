import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'observation_provider.dart';
import 'constellation_provider.dart';
import 'timecapsule_provider.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final bool isUnlocked;
  final int progress;
  final int goal;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.isUnlocked,
    required this.progress,
    required this.goal,
  });
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
      description: '初めて星座を観測した',
      emoji: '🌟',
      isUnlocked: firstObs >= 1,
      progress: firstObs.clamp(0, 1),
      goal: 1,
    ),
    Achievement(
      id: 'city_hunter',
      title: 'シティハンター',
      description: '光害の中で10回観測（Bortle 7以上）',
      emoji: '🏙️',
      isUnlocked: cityObs >= 10,
      progress: cityObs.clamp(0, 10),
      goal: 10,
    ),
    Achievement(
      id: 'star_reader',
      title: '星読み師',
      description: '全88星座を図鑑に収めた',
      emoji: '📚',
      isUnlocked: totalUnlocked >= 88,
      progress: totalUnlocked.clamp(0, 88),
      goal: 88,
    ),
    Achievement(
      id: 'time_traveler',
      title: '時間旅行者',
      description: 'タイムカプセルイベントを3回記録',
      emoji: '⏳',
      isUnlocked: capsuleCount >= 3,
      progress: capsuleCount.clamp(0, 3),
      goal: 3,
    ),
    Achievement(
      id: 'repeater',
      title: '星の常連',
      description: '同じ星座を5回観測',
      emoji: '🔄',
      isUnlocked: maxRepeat >= 5,
      progress: maxRepeat.clamp(0, 5),
      goal: 5,
    ),
    Achievement(
      id: 'dark_sky',
      title: 'ダークスカイハンター',
      description: 'Bortle 3以下の暗い空で観測',
      emoji: '🌌',
      isUnlocked: darkSkyObs >= 1,
      progress: darkSkyObs.clamp(0, 1),
      goal: 1,
    ),
    Achievement(
      id: 'zodiac_complete',
      title: '黄道コンプリート',
      description: '黄道12星座をすべて図鑑に登録した',
      emoji: '♾️',
      isUnlocked: zodiacCount >= 12,
      progress: zodiacCount.clamp(0, 12),
      goal: 12,
    ),
    Achievement(
      id: 'collector_25',
      title: 'コレクター',
      description: '25個の星座を図鑑に登録した',
      emoji: '🎖️',
      isUnlocked: totalUnlocked >= 25,
      progress: totalUnlocked.clamp(0, 25),
      goal: 25,
    ),
    Achievement(
      id: 'collector_50',
      title: '大コレクター',
      description: '50個の星座を図鑑に登録した',
      emoji: '🏆',
      isUnlocked: totalUnlocked >= 50,
      progress: totalUnlocked.clamp(0, 50),
      goal: 50,
    ),
    Achievement(
      id: 'ultra_city_master',
      title: 'ウルトラシティマスター',
      description: '最極限の光害（Bortle 8-9）で20回観測',
      emoji: '🌃',
      isUnlocked: ultraCityObs >= 20,
      progress: ultraCityObs.clamp(0, 20),
      goal: 20,
    ),
  ];
});

// ユーザーの称号（最上位の解放済みアチーブメント）
final userTitleProvider = Provider<String>((ref) {
  final achievements = ref.watch(achievementsProvider);
  final unlocked = achievements.where((a) => a.isUnlocked).toList();

  if (unlocked.any((a) => a.id == 'ultra_city_master')) return 'ウルトラシティマスター';
  if (unlocked.any((a) => a.id == 'star_reader')) return '星読み師';
  if (unlocked.any((a) => a.id == 'collector_50')) return '大コレクター';
  if (unlocked.any((a) => a.id == 'zodiac_complete')) return '黄道マスター';
  if (unlocked.any((a) => a.id == 'time_traveler')) return '時間旅行者';
  if (unlocked.any((a) => a.id == 'city_hunter')) return 'シティハンター';
  if (unlocked.any((a) => a.id == 'dark_sky')) return 'ダークスカイハンター';
  if (unlocked.any((a) => a.id == 'collector_25')) return 'コレクター';
  if (unlocked.any((a) => a.id == 'repeater')) return '星の常連';
  if (unlocked.any((a) => a.id == 'first_observation')) return '見習い星詠み';
  return '星初心者';
});

// 解放済みアチーブメント数
final unlockedAchievementCountProvider = Provider<int>((ref) {
  return ref.watch(achievementsProvider).where((a) => a.isUnlocked).length;
});
