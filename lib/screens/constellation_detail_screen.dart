import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/constellation_provider.dart';
import '../providers/observation_provider.dart';
import '../models/constellation.dart';
import '../models/observation.dart';
import '../services/constellation_art.dart';
import '../data/stars_data.dart';
import '../providers/constellation_nickname_provider.dart';
import '../models/constellation_nickname.dart';

class ConstellationDetailScreen extends ConsumerWidget {
  final String constellationId;
  const ConstellationDetailScreen({super.key, required this.constellationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final constellationAsync =
        ref.watch(constellationByIdProvider(constellationId));
    final allObservations = ref.watch(observationListProvider);
    final myObservations = allObservations
        .where((o) => o.constellationId == constellationId)
        .toList();
    final unlockedIds = ref.watch(unlockedIdsProvider);
    final isUnlocked = unlockedIds.contains(constellationId);

    return constellationAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('エラー: $e')),
      ),
      data: (constellation) {
        if (constellation == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('星座が見つかりません')),
          );
        }
        return _DetailContent(
          constellation: constellation,
          isUnlocked: isUnlocked,
          observations: myObservations,
        );
      },
    );
  }
}

class _DetailContent extends StatelessWidget {
  final Constellation constellation;
  final bool isUnlocked;
  final List<Observation> observations;

  const _DetailContent({
    required this.constellation,
    required this.isUnlocked,
    required this.observations,
  });

  int get _maxDifficulty {
    if (observations.isEmpty) return 0;
    return observations
        .map((o) => o.difficultyStars)
        .reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _HeroAppBar(constellation: constellation, isUnlocked: isUnlocked),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  _StatsRow(
                    constellation: constellation,
                    observationCount: observations.length,
                    maxDifficulty: _maxDifficulty,
                  ),
                  const SizedBox(height: 24),

                  // Star Naming
                  _StarNamingSection(constellation: constellation),
                  const SizedBox(height: 24),

                  // Mythology
                  _SectionTitle('神話・伝説'),
                  const SizedBox(height: 8),
                  Text(
                    constellation.mythologyText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.8,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Astronomy data
                  _SectionTitle('天文データ'),
                  const SizedBox(height: 8),
                  _AstronomyDataCard(constellation: constellation),
                  const SizedBox(height: 24),

                  // Light-year Time Travel
                  _SectionTitle('光年の時間旅行'),
                  const SizedBox(height: 8),
                  _LightYearCard(constellation: constellation),
                  const SizedBox(height: 24),

                  // Observation plan
                  _SectionTitle('観測プラン'),
                  const SizedBox(height: 8),
                  _ObservationPlanCard(constellation: constellation),
                  const SizedBox(height: 24),

                  // Observation history
                  if (observations.isNotEmpty) ...[
                    _SectionTitle('観測記録'),
                    const SizedBox(height: 8),
                    ...observations.map(
                      (o) => _ObservationHistoryTile(observation: o),
                    ),
                  ] else ...[
                    _SectionTitle('観測記録'),
                    const SizedBox(height: 8),
                    _EmptyObservationCard(constellation: constellation),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'manual_obs',
            onPressed: () =>
                context.push('/add-observation/${constellation.id}'),
            icon: const Icon(Icons.edit_note),
            label: const Text('手動記録'),
            backgroundColor: Colors.teal,
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: 'ar_obs',
            onPressed: () => context.push('/ar'),
            icon: const Icon(Icons.camera_alt),
            label: const Text('AR観測'),
          ),
        ],
      ),
    );
  }
}

class _HeroAppBar extends StatelessWidget {
  final Constellation constellation;
  final bool isUnlocked;

  const _HeroAppBar({
    required this.constellation,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: colorScheme.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.star_border, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.indigo.shade900,
                Colors.purple.shade800,
              ],
            ),
          ),
          child: Stack(
            children: [
              // 星座ラインアート（データがある星座のみ）
              if (constellationArts.containsKey(constellation.id))
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CustomPaint(
                      painter: ConstellationLinePainter(
                        art: constellationArts[constellation.id]!,
                        starColor: Colors.white,
                        lineColor: const Color(0x55AACCFF),
                        starRadius: 2.5,
                      ),
                    ),
                  ),
                ),
              // 中央テキスト
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // アートがない星座はemoji大表示、ある星座は小さく右上に
                    if (!constellationArts.containsKey(constellation.id))
                      Text(
                        constellation.emoji,
                        style: const TextStyle(fontSize: 64),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          constellation.emoji,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      constellation.nameJa,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 8)],
                      ),
                    ),
                    Text(
                      constellation.nameEn,
                      style: TextStyle(
                        color: Colors.white.withAlpha(180),
                        fontSize: 14,
                        shadows: const [Shadow(blurRadius: 4)],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final Constellation constellation;
  final int observationCount;
  final int maxDifficulty;

  const _StatsRow({
    required this.constellation,
    required this.observationCount,
    required this.maxDifficulty,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              label: '観測回数',
              value: '$observationCount回',
              icon: Icons.visibility,
            ),
            _StatDivider(),
            _StatItem(
              label: '難易度（基本）',
              value: _starsStr(constellation.baseDifficulty, 5),
              icon: Icons.location_on,
            ),
            _StatDivider(),
            _StatItem(
              label: '最高難易度',
              value: maxDifficulty > 0 ? _starsStr(maxDifficulty, 3) : '未観測',
              icon: Icons.emoji_events,
            ),
          ],
        ),
      ),
    );
  }

  String _starsStr(int filled, int total) =>
      '★' * filled + '☆' * (total - filled);
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 40, width: 1, color: Colors.grey.shade300);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}

class _AstronomyDataCard extends StatelessWidget {
  final Constellation constellation;
  const _AstronomyDataCard({required this.constellation});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _DataRow('赤経', constellation.rightAscension),
            _DataRow('赤緯', constellation.declination),
            _DataRow(
              '主要な星',
              constellation.brightStars.join('、'),
            ),
            _DataRow('見頃', constellation.peakMonths),
            _DataRow(
              'カテゴリ',
              _categoryName(constellation.category),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryName(String cat) {
    switch (cat) {
      case ConstellationCategory.zodiac:
        return '黄道12星座';
      case ConstellationCategory.northern:
        return '北天の星座';
      case ConstellationCategory.southern:
        return '南天の星座';
      default:
        return cat;
    }
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  const _DataRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ObservationHistoryTile extends StatelessWidget {
  final Observation observation;
  const _ObservationHistoryTile({required this.observation});

  @override
  Widget build(BuildContext context) {
    final date =
        '${observation.timestamp.year}-${observation.timestamp.month.toString().padLeft(2, '0')}-${observation.timestamp.day.toString().padLeft(2, '0')}';
    final time =
        '${observation.timestamp.hour.toString().padLeft(2, '0')}:${observation.timestamp.minute.toString().padLeft(2, '0')}';
    final difficultyStr =
        '★' * observation.difficultyStars + '☆' * (3 - observation.difficultyStars);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _bortleColor(observation.bortleScale),
          child: Text(
            '${observation.bortleScale}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text('$date $time'),
        subtitle: Text(
          '${observation.locationName}  $difficultyStr\n${observation.notes}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: Text(
          '天気: ${observation.weather}',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }

  Color _bortleColor(int scale) {
    if (scale >= 7) return Colors.red.shade700;
    if (scale >= 4) return Colors.orange.shade600;
    return Colors.green.shade700;
  }
}

class _ObservationPlanCard extends StatelessWidget {
  final Constellation constellation;
  const _ObservationPlanCard({required this.constellation});

  String _getSeasonStatus(String peakMonths) {
    final month = DateTime.now().month;
    // 簡易判定: peakMonthsに現在の月が含まれているか
    if (peakMonths.contains('通年')) return '通年観測可能 🌟';
    if (peakMonths.contains('${month}月')) return '今月が見頃です！ ✨';

    // 次の見頃を推定
    final nums = RegExp(r'\d+').allMatches(peakMonths).map((m) => int.parse(m.group(0)!)).toList();
    if (nums.isEmpty) return '季節限定（詳細はデータを確認）';

    final nextMonth = nums.firstWhere((m) => m > month, orElse: () => nums.first);
    if (nextMonth > month) {
      return '来月（${nextMonth}月）が見頃です';
    } else {
      return '来年（${nextMonth}月）が見頃です';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 季節情報
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getSeasonStatus(constellation.peakMonths),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 難易度説明
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 20,
                  color: Colors.amber.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '基本難易度',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Row(
                        children: [
                          ...List.generate(5, (i) {
                            return Icon(
                              i < constellation.baseDifficulty
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: Colors.amber.shade700,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            constellation.baseDifficulty == 5
                                ? '最高難易度'
                                : constellation.baseDifficulty == 1
                                    ? '最易'
                                    : '中程度',
                            style: TextStyle(
                              color: Colors.amber.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 観測推奨
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      constellation.baseDifficulty >= 4
                          ? '都市部での観測は難しいため、暗い空での観測をお勧めします'
                          : '見やすい星座です。どこからでも観測できます！',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyObservationCard extends StatelessWidget {
  final Constellation constellation;
  const _EmptyObservationCard({required this.constellation});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.nights_stay,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'まだ${constellation.nameJa}を観測していません',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () =>
                      context.push('/add-observation/${constellation.id}'),
                  icon: const Icon(Icons.edit_note),
                  label: const Text('手動記録'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => context.push('/ar'),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('AR観測'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LightYearCard extends StatelessWidget {
  final Constellation constellation;
  const _LightYearCard({required this.constellation});

  @override
  Widget build(BuildContext context) {
    final starData = getStarDataByConstellationId(constellation.id);

    if (starData == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${constellation.nameJa}の光年データはまだ公開されていません',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final now = DateTime.now();
    final originYear = starData.getOriginYear(now.year);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 主要な星
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 20,
                  color: Colors.amber.shade400,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        starData.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        starData.nameEn,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 光年距離
            Row(
              children: [
                Icon(
                  Icons.straighten,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '光の旅の距離',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        starData.getLightYearDescription(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 時間旅行情報
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✨ 時間旅行のミステリー',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.deepPurple.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '今見ている光は${originYear}年に${starData.name}から発せられたものです。\n'
                    '${now.year - originYear}年前の光を今、あなたの目で見ています。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.deepPurple.shade700,
                          height: 1.6,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarNamingSection extends ConsumerWidget {
  final Constellation constellation;
  const _StarNamingSection({required this.constellation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nickname = ref.watch(constellationNicknameProvider(constellation.id));

    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star_rate, color: Colors.amber.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  '📛 あなたの命名',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (nickname != null) ...[
              Text(
                '「${nickname.nickname}」',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '理由: ${nickname.reason}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.amber.shade700,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showEditDialog(context, ref, nickname),
                    icon: const Icon(Icons.edit),
                    label: const Text('編集'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await ref
                          .read(constellationNicknameMapProvider.notifier)
                          .removeNickname(constellation.id);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('削除'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                'この星座にあなただけの名前をつけてみませんか？',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.amber.shade800,
                    ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showEditDialog(context, ref, null),
                  icon: const Icon(Icons.add),
                  label: const Text('名前をつける'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    ConstellationNickname? existing,
  ) {
    final nicknameCtrl = TextEditingController(text: existing?.nickname ?? '');
    final reasonCtrl = TextEditingController(text: existing?.reason ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing != null ? '命名を編集' : '新しい命名'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nicknameCtrl,
                decoration: const InputDecoration(
                  labelText: '星座の呼び名',
                  hintText: '例: 輝く者',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'つけた理由',
                  hintText: '例: 初観測の時、星が特に明るかったから',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nicknameCtrl.text.isNotEmpty) {
                final nickname = ConstellationNickname(
                  constellationId: constellation.id,
                  nickname: nicknameCtrl.text,
                  reason: reasonCtrl.text,
                  createdAt: existing?.createdAt ?? DateTime.now(),
                );
                ref.read(constellationNicknameMapProvider.notifier).setNickname(nickname);
                Navigator.pop(ctx);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    ).then((_) {
      nicknameCtrl.dispose();
      reasonCtrl.dispose();
    });
  }
}
