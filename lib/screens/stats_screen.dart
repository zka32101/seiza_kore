import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/constellation_provider.dart';
import '../providers/observation_provider.dart';
import '../providers/achievement_provider.dart';
import '../models/observation.dart';
import '../services/bortle_service.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlockedCount = ref.watch(unlockedIdsProvider).length;
    final favoriteCount = ref.watch(favoriteIdsProvider).length;
    final observations = ref.watch(observationListProvider);
    final constellationsAsync = ref.watch(constellationListProvider);
    final earnedCount = ref.watch(unlockedAchievementCountProvider);
    final userTitle = ref.watch(userTitleProvider);
    final totalAchievements = ref.watch(achievementsProvider).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('詳細統計'),
        centerTitle: true,
      ),
      body: constellationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (constellations) {
          final progress = unlockedCount / 88;
          final dark = observations.where((o) => o.bortleScale <= 3).length;
          final suburb =
              observations.where((o) => o.bortleScale >= 4 && o.bortleScale <= 6).length;
          final city = observations.where((o) => o.bortleScale >= 7).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 実績バナー
                GestureDetector(
                  onTap: () => context.push('/achievements'),
                  child: Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Text('🏅', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                ),
                                Text(
                                  '実績 $earnedCount / $totalAchievements 解除',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // コレクション進度
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '図鑑コレクション',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 12,
                            backgroundColor: Colors.grey.shade200,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatCol('取得', '$unlockedCount', Colors.blue),
                            _StatCol('未取得', '${88 - unlockedCount}',
                                Colors.grey.shade400),
                            _StatCol('お気に入り', '$favoriteCount',
                                Colors.pink.shade400),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 観測分析
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '観測環境の分析',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _BortleBar(
                          label: '🌌 暗い空（Bortle 1-3）',
                          count: dark,
                          total: observations.length,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(height: 8),
                        _BortleBar(
                          label: '🌆 郊外（Bortle 4-6）',
                          count: suburb,
                          total: observations.length,
                          color: Colors.orange.shade500,
                        ),
                        const SizedBox(height: 8),
                        _BortleBar(
                          label: '🏙️ 都市（Bortle 7-9）',
                          count: city,
                          total: observations.length,
                          color: Colors.red.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // カテゴリ別統計
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'カテゴリ別取得数',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _CategoryStat(
                          label: '黄道12星座',
                          count: constellations
                              .where((c) =>
                                  c.category == 'zodiac' &&
                                  ref
                                      .watch(unlockedIdsProvider)
                                      .contains(c.id))
                              .length,
                          total: 12,
                          color: Colors.amber,
                        ),
                        const SizedBox(height: 8),
                        _CategoryStat(
                          label: '北天の星座',
                          count: constellations
                              .where((c) =>
                                  c.category == 'northern' &&
                                  ref
                                      .watch(unlockedIdsProvider)
                                      .contains(c.id))
                              .length,
                          total: 31,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        _CategoryStat(
                          label: '南天の星座',
                          count: constellations
                              .where((c) =>
                                  c.category == 'southern' &&
                                  ref
                                      .watch(unlockedIdsProvider)
                                      .contains(c.id))
                              .length,
                          total: 44,
                          color: Colors.teal,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCol(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _BortleBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _BortleBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : count / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            Text(
              '$count回',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _CategoryStat extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _CategoryStat({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = count / total;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$count/$total',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
