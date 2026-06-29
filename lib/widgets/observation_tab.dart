import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/observation_provider.dart';
import '../providers/constellation_provider.dart';
import '../providers/timecapsule_provider.dart';
import '../models/observation.dart';
import '../models/constellation.dart';
import '../services/moon_service.dart';
import 'starfield_background.dart';

class ObservationTab extends ConsumerWidget {
  const ObservationTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final observations = ref.watch(observationListProvider);
    final activeEvents = ref.watch(activeEventsProvider);
    final unlockedCount = ref.watch(unlockedIdsProvider).length;
    final recommendedAsync = ref.watch(recommendedConstellationProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active timecapsule alert
          if (activeEvents.isNotEmpty)
            GestureDetector(
              onTap: () => context.push('/timecapsule'),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade600,
                      Colors.indigo.shade700,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('⏰', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '今すぐ観測チャンス！',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            activeEvents.first.name,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Today's stats card
                _TodayCard(
                  unlockedCount: unlockedCount,
                  recommendedAsync: recommendedAsync,
                ),
                const SizedBox(height: 20),

                // AR observation button (main CTA)
                _ARButton(),
                const SizedBox(height: 20),

                // Recent observations
                Text(
                  '最近の観測',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                if (observations.isEmpty)
                  _EmptyObservations()
                else
                  ...observations.take(5).map(
                    (o) => _RecentObservationTile(observation: o),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  final int unlockedCount;
  final AsyncValue<Constellation?> recommendedAsync;
  const _TodayCard({
    required this.unlockedCount,
    required this.recommendedAsync,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final bool isNight = hour >= 20 || hour < 6;

    String greeting;
    String greetingIcon;
    if (hour < 5) {
      greeting = '深夜の星空観測に最適';
      greetingIcon = '🌌';
    } else if (hour < 12) {
      greeting = '今夜の観測計画を立てよう';
      greetingIcon = '🌅';
    } else if (hour < 17) {
      greeting = '日没後に星座を探しに行こう';
      greetingIcon = '☀️';
    } else if (hour < 20) {
      greeting = 'もうすぐ星が輝き始めます';
      greetingIcon = '🌆';
    } else {
      greeting = '今夜は絶好の観測日和！';
      greetingIcon = '✨';
    }

    final moonAge = MoonService.moonAge(now);
    final moonEmoji = MoonService.moonPhaseEmoji(moonAge);
    final moonPhaseName = MoonService.moonPhaseName(moonAge);
    final moonGood = MoonService.isGoodForObservation(moonAge);

    final recommendedName = recommendedAsync.when(
      data: (c) => c?.nameJa ?? '—',
      loading: () => '...',
      error: (_, __) => '—',
    );
    final recommendedEmoji = recommendedAsync.when(
      data: (c) => c?.emoji ?? '⭐',
      loading: () => '⭐',
      error: (_, __) => '⭐',
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 180,
        child: StarfieldBackground(
          seed: isNight ? 999 : 888,
          starCount: isNight ? 320 : 180,
          animate: isNight,
          overlayColor: isNight
              ? const Color(0x18000520)
              : const Color(0x55030520),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // グリーティング
                Row(
                  children: [
                    Text(greetingIcon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      greeting,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // 3カラム情報
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NightStat(
                      icon: '📚',
                      value: '$unlockedCount/88',
                      label: '図鑑',
                    ),
                    _NightDivider(),
                    _NightStat(
                      icon: recommendedEmoji,
                      value: recommendedName,
                      label: '今月の推奨',
                    ),
                    _NightDivider(),
                    _NightStat(
                      icon: moonEmoji,
                      value: '${moonAge.toInt()}日',
                      label: moonGood ? '観測◎' : '月明かり注意',
                      labelColor: moonGood
                          ? const Color(0xFF88DDAA)
                          : const Color(0xFFFFCC77),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // 月相名
                Center(
                  child: Text(
                    moonPhaseName,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NightStat extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color? labelColor;
  const _NightStat({
    required this.icon,
    required this.value,
    required this.label,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 6, color: Colors.black)],
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(
            color: labelColor ?? Colors.white54,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _NightDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 44, color: Colors.white12);
}

class _ARButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/ar'),
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade700,
              Colors.purple.shade700,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withAlpha(80),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, color: Colors.white, size: 40),
            SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AR観測を始める',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'スマホを夜空に向けよう',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentObservationTile extends ConsumerWidget {
  final Observation observation;
  const _RecentObservationTile({required this.observation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final constellationAsync =
        ref.watch(constellationByIdProvider(observation.constellationId));
    final constName = constellationAsync.when(
      data: (c) => c?.nameJa ?? observation.constellationId,
      loading: () => '...',
      error: (_, __) => observation.constellationId,
    );
    final diffStr =
        '★' * observation.difficultyStars + '☆' * (3 - observation.difficultyStars);
    final date =
        '${observation.timestamp.month}/${observation.timestamp.day}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => context.push('/constellation/${observation.constellationId}'),
        leading: CircleAvatar(
          backgroundColor: _bortleColor(observation.bortleScale).withAlpha(30),
          child: Text(
            constellationAsync.when(
              data: (c) => c?.emoji ?? '⭐',
              loading: () => '⭐',
              error: (_, __) => '⭐',
            ),
            style: const TextStyle(fontSize: 18),
          ),
        ),
        title: Text(constName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$date  ${observation.locationName}'),
        trailing: Text(
          diffStr,
          style: const TextStyle(color: Colors.amber),
        ),
      ),
    );
  }

  Color _bortleColor(int scale) {
    if (scale >= 7) return Colors.red;
    if (scale >= 4) return Colors.orange;
    return Colors.green;
  }
}

class _EmptyObservations extends StatelessWidget {
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
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            const Text(
              'まだ観測記録がありません\nAR観測ボタンから始めてみよう！',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
