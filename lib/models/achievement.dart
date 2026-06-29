class Achievement {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final AchievementCategory category;

  const Achievement({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.category,
  });
}

enum AchievementCategory { collection, observation, exploration }

const achievements = [
  Achievement(
    id: 'first_unlock',
    emoji: '🌟',
    title: 'はじめての一歩',
    description: '最初の星座を図鑑に登録した',
    category: AchievementCategory.collection,
  ),
  Achievement(
    id: 'zodiac_complete',
    emoji: '♾️',
    title: '黄道コンプリート',
    description: '黄道12星座をすべて集めた',
    category: AchievementCategory.collection,
  ),
  Achievement(
    id: 'collector_25',
    emoji: '🎖️',
    title: 'コレクター',
    description: '25個の星座を図鑑に登録した',
    category: AchievementCategory.collection,
  ),
  Achievement(
    id: 'collector_50',
    emoji: '🏆',
    title: '大コレクター',
    description: '50個の星座を図鑑に登録した',
    category: AchievementCategory.collection,
  ),
  Achievement(
    id: 'complete_all',
    emoji: '👑',
    title: '完全図鑑',
    description: '全88星座をコンプリートした',
    category: AchievementCategory.collection,
  ),
  Achievement(
    id: 'first_observation',
    emoji: '🔭',
    title: '観測開始',
    description: '初めて星座を観測した',
    category: AchievementCategory.observation,
  ),
  Achievement(
    id: 'observer_10',
    emoji: '🌌',
    title: '観測家',
    description: '10回以上の観測記録を残した',
    category: AchievementCategory.observation,
  ),
  Achievement(
    id: 'dark_sky',
    emoji: '🏕️',
    title: '暗空探検家',
    description: 'Bortle 1-3の暗い空で観測した',
    category: AchievementCategory.exploration,
  ),
];
