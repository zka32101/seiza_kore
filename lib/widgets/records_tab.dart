import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/observation_provider.dart';
import '../models/observation.dart';

class RecordsTab extends ConsumerWidget {
  const RecordsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(observationFilterProvider);
    final observations = ref.watch(filteredObservationsProvider);

    return Column(
      children: [
        // Timecapsule banner
        GestureDetector(
          onTap: () => context.push('/timecapsule'),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade700, Colors.purple.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Text('⏰', style: TextStyle(fontSize: 24)),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'タイムカプセル天体',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '特別な天文イベントの記録を見る',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Stats summary
        _BortleStatsBar(observations: ref.watch(observationListProvider)),
        const SizedBox(height: 4),

        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _FilterChip(label: '全て', value: 'all', current: filter),
              _FilterChip(label: '星座', value: 'constellation', current: filter),
              _FilterChip(label: '天体', value: 'celestial', current: filter),
            ],
          ),
        ),

        // Timeline
        Expanded(
          child: observations.isEmpty
              ? const _EmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: observations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final obs = observations[index];
                    return Dismissible(
                      key: Key(obs.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      onDismissed: (_) {
                        ref
                            .read(observationListProvider.notifier)
                            .deleteObservation(obs.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('観測記録を削除しました'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: _ObservationCard(observation: obs),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _BortleStatsBar extends StatelessWidget {
  final List<Observation> observations;
  const _BortleStatsBar({required this.observations});

  @override
  Widget build(BuildContext context) {
    if (observations.isEmpty) return const SizedBox.shrink();

    final dark = observations.where((o) => o.bortleScale <= 3).length;
    final suburb = observations.where((o) => o.bortleScale >= 4 && o.bortleScale <= 6).length;
    final city = observations.where((o) => o.bortleScale >= 7).length;
    final total = observations.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '観測環境の分布',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              _StatBar(
                label: '🌌 暗い空（1-3）',
                count: dark,
                total: total,
                color: Colors.green.shade600,
              ),
              const SizedBox(height: 4),
              _StatBar(
                label: '🌆 郊外（4-6）',
                count: suburb,
                total: total,
                color: Colors.orange.shade500,
              ),
              const SizedBox(height: 4),
              _StatBar(
                label: '🏙️ 都市（7-9）',
                count: city,
                total: total,
                color: Colors.red.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _StatBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : count / total;
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: Theme.of(context).textTheme.labelSmall),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              color: color,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count回',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}

class _FilterChip extends ConsumerWidget {
  final String label;
  final String value;
  final String current;
  const _FilterChip(
      {required this.label, required this.value, required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: current == value,
        onSelected: (_) =>
            ref.read(observationFilterProvider.notifier).state = value,
      ),
    );
  }
}

class _ObservationCard extends StatelessWidget {
  final Observation observation;
  const _ObservationCard({required this.observation});

  @override
  Widget build(BuildContext context) {
    final date =
        '${observation.timestamp.year}-${observation.timestamp.month.toString().padLeft(2, '0')}-${observation.timestamp.day.toString().padLeft(2, '0')}';
    final time =
        '${observation.timestamp.hour.toString().padLeft(2, '0')}:${observation.timestamp.minute.toString().padLeft(2, '0')}';
    final diffStr =
        '★' * observation.difficultyStars + '☆' * (3 - observation.difficultyStars);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$date $time',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                // Bortle badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _bortleColor(observation.bortleScale).withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _bortleColor(observation.bortleScale)),
                  ),
                  child: Text(
                    'Bortle ${observation.bortleScale}',
                    style: TextStyle(
                      color: _bortleColor(observation.bortleScale),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  observation.locationName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                Text(
                  diffStr,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '天気: ${observation.weather}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (observation.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                observation.notes,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _bortleColor(int scale) {
    if (scale >= 7) return Colors.red.shade600;
    if (scale >= 4) return Colors.orange.shade600;
    return Colors.green.shade600;
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.nights_stay,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'まだ観測記録がありません',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text('AR観測ボタンで夜空を観測してみよう'),
        ],
      ),
    );
  }
}
