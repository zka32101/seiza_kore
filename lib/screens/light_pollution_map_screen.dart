import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/bortle_service.dart';
import '../providers/observation_provider.dart';
import '../providers/constellation_provider.dart';

class LightPollutionMapScreen extends ConsumerWidget {
  const LightPollutionMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final observations = ref.watch(observationListProvider);
    final constellations = ref.watch(constellationListProvider);

    return constellations.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('エラー: $e'))),
      data: (const_list) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('🌍 光害マップ & 観測難易度'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header explanation
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📊 観測条件の選択肢',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'あなたの周辺の光害レベル（Bortleスケール）に応じて、観測可能な星座と難易度が変わります。'
                          '暗い空への移動で、より難しい（そして美しい）星座を見つけることができます。',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                height: 1.6,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Bortle Scale Chart
                _SectionTitle('🌙 Bortleスケール基準'),
                const SizedBox(height: 12),
                ..._buildBortleChart(context),

                const SizedBox(height: 32),

                // Observation statistics
                _SectionTitle('📈 あなたの観測統計'),
                const SizedBox(height: 12),
                _ObservationStatsCard(observations: observations),

                const SizedBox(height: 32),

                // Difficulty distribution
                _SectionTitle('⭐ 難易度別・観測可能な星座'),
                const SizedBox(height: 12),
                ..._buildDifficultyDistribution(context, const_list.toList()),

                const SizedBox(height: 32),

                // Tips
                _SectionTitle('💡 観測のコツ'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _TipItem(
                          icon: Icons.location_on,
                          title: '明るい場所での観測',
                          description: '都市部（Bortle 7-9）では、基本難易度2以下の星座を探しましょう。シリウスやベテルギウスなど明るい星が狙い目です。',
                        ),
                        const SizedBox(height: 12),
                        _TipItem(
                          icon: Icons.directions_car,
                          title: '郊外への移動',
                          description: '郊外（Bortle 4-6）に移動すれば、難易度3-4の星座も観測可能に。週末の天体観測ツアーを計画してみましょう。',
                        ),
                        const SizedBox(height: 12),
                        _TipItem(
                          icon: Icons.dark_mode,
                          title: 'ダークスカイ探索',
                          description: '山間部（Bortle 1-3）では、難易度5の最高難度星座も見えます。流星群の季節は特に最高の観測地を探しましょう。',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildBortleChart(BuildContext context) {
    final service = BortleService.instance;
    return List.generate(9, (index) {
      final bortle = index + 1;
      final info = service.getBortleInfo(bortle);
      final starCount = _getVisibleStarCount(bortle);

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  _getBortleColor(bortle).withAlpha(100),
                  _getBortleColor(bortle).withAlpha(200),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bortle $bortle: ${info.label}',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              info.description,
                              style: Theme.of(context).textTheme.labelSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '⭐ $starCount個',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _buildDifficultyDistribution(
    BuildContext context,
    List<dynamic> constellationList,
  ) {
    final byDifficulty = <int, int>{};
    for (final c in constellationList) {
      final diff = c.baseDifficulty as int;
      byDifficulty[diff] = (byDifficulty[diff] ?? 0) + 1;
    }

    return List.generate(5, (diffIndex) {
      final difficulty = diffIndex + 1;
      final count = byDifficulty[difficulty] ?? 0;
      final percentage = (count / constellationList.length * 100).toStringAsFixed(0);

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '難易度: ${'★' * difficulty}${'☆' * (5 - difficulty)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '$count個 ($percentage%)',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: count / constellationList.length,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(_getDifficultyColor(difficulty)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Color _getBortleColor(int bortle) {
    if (bortle <= 2) return Colors.indigo.shade800;
    if (bortle <= 3) return Colors.blue.shade800;
    if (bortle <= 5) return Colors.purple.shade700;
    if (bortle <= 7) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  Color _getDifficultyColor(int difficulty) {
    if (difficulty == 1) return Colors.green;
    if (difficulty == 2) return Colors.lightGreen;
    if (difficulty == 3) return Colors.yellow;
    if (difficulty == 4) return Colors.orange;
    return Colors.red;
  }

  int _getVisibleStarCount(int bortle) {
    // Rough estimate of visible stars at each Bortle level
    final counts = {
      1: 6000,
      2: 3500,
      3: 2000,
      4: 700,
      5: 300,
      6: 100,
      7: 20,
      8: 5,
      9: 1,
    };
    return counts[bortle] ?? 0;
  }
}

class _ObservationStatsCard extends StatelessWidget {
  final List observations;
  const _ObservationStatsCard({required this.observations});

  @override
  Widget build(BuildContext context) {
    int totalObs = observations.length;
    int brightObs = observations.where((o) => o.bortleScale >= 7).length;
    int darkObs = observations.where((o) => o.bortleScale <= 3).length;
    double avgBortle = totalObs > 0
        ? observations.map((o) => o.bortleScale).reduce((a, b) => a + b) / totalObs
        : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  '$totalObs',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text('観測回数', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
            Column(
              children: [
                Text(
                  avgBortle.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text('平均Bortle', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
            Column(
              children: [
                Text(
                  '$brightObs',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                ),
                Text('都市観測', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
            Column(
              children: [
                Text(
                  '$darkObs',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                ),
                Text('暗空観測', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _TipItem({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.5,
                      color: Colors.grey.shade700,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
