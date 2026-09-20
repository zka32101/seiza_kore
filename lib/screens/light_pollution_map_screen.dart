import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/bortle_service.dart';
import '../services/location_service.dart';
import '../providers/observation_provider.dart';
import '../providers/constellation_provider.dart';

class LightPollutionMapScreen extends ConsumerStatefulWidget {
  const LightPollutionMapScreen({super.key});

  @override
  ConsumerState<LightPollutionMapScreen> createState() =>
      _LightPollutionMapScreenState();
}

class _LightPollutionMapScreenState
    extends ConsumerState<LightPollutionMapScreen> {
  bool _loadingLocation = false;
  int? _currentBortle;
  String? _locationError;

  Future<void> _detectCurrentLocation() async {
    setState(() {
      _loadingLocation = true;
      _locationError = null;
    });
    final result = await LocationService.getCurrentLocation();
    if (!mounted) return;
    switch (result) {
      case LocationSuccess(:final latitude, :final longitude):
        final bortle =
            BortleService.instance.getBortleScale(latitude, longitude);
        setState(() {
          _currentBortle = bortle;
          _loadingLocation = false;
        });
      case LocationFailure(:final message):
        setState(() {
          _locationError = message;
          _loadingLocation = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final observations = ref.watch(observationListProvider);
    final constellations = ref.watch(constellationListProvider);

    return constellations.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text(l10n.lightPollutionLoadError(e.toString())))),
      data: (const_list) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.lightPollutionTitle),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current location Bortle detection
                _CurrentLocationCard(
                  loading: _loadingLocation,
                  bortle: _currentBortle,
                  error: _locationError,
                  onDetect: _detectCurrentLocation,
                ),
                const SizedBox(height: 24),

                // Header explanation
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.lightPollutionConditionsTitle,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.lightPollutionConditionsBody,
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
                _SectionTitle(l10n.lightPollutionBortleScaleSectionTitle),
                const SizedBox(height: 12),
                ..._buildBortleChart(context),

                const SizedBox(height: 32),

                // Observation statistics
                _SectionTitle(l10n.lightPollutionStatsSectionTitle),
                const SizedBox(height: 12),
                _ObservationStatsCard(observations: observations),

                const SizedBox(height: 32),

                // Difficulty distribution
                _SectionTitle(l10n.lightPollutionDifficultySectionTitle),
                const SizedBox(height: 12),
                ..._buildDifficultyDistribution(context, const_list.toList()),

                const SizedBox(height: 32),

                // Tips
                _SectionTitle(l10n.lightPollutionTipsSectionTitle),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _TipItem(
                          icon: Icons.location_on,
                          title: l10n.lightPollutionTip1Title,
                          description: l10n.lightPollutionTip1Description,
                        ),
                        const SizedBox(height: 12),
                        _TipItem(
                          icon: Icons.directions_car,
                          title: l10n.lightPollutionTip2Title,
                          description: l10n.lightPollutionTip2Description,
                        ),
                        const SizedBox(height: 12),
                        _TipItem(
                          icon: Icons.dark_mode,
                          title: l10n.lightPollutionTip3Title,
                          description: l10n.lightPollutionTip3Description,
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
    final l10n = AppLocalizations.of(context)!;
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
                        l10n.lightPollutionStarCount(starCount),
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
    final l10n = AppLocalizations.of(context)!;
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
                      l10n.lightPollutionDifficultyLabel(
                          '${'★' * difficulty}${'☆' * (5 - difficulty)}'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      l10n.lightPollutionCountPercentage(count, percentage),
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

class _CurrentLocationCard extends StatelessWidget {
  final bool loading;
  final int? bortle;
  final String? error;
  final VoidCallback onDetect;

  const _CurrentLocationCard({
    required this.loading,
    required this.bortle,
    required this.error,
    required this.onDetect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final service = BortleService.instance;
    final info = bortle != null ? service.getBortleInfo(bortle!) : null;

    return Card(
      color: Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.my_location, color: Colors.indigo.shade700),
                const SizedBox(width: 8),
                Text(
                  l10n.lightPollutionCurrentLocationTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (info != null) ...[
              Text(
                l10n.lightPollutionBortleLabel(bortle!, info.label),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(info.description, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                l10n.lightPollutionDifficultyEstimateLabel(
                    service.getDifficultyLabel(bortle!)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
            ] else if (error != null) ...[
              Text(
                error!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 13),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: loading ? null : onDetect,
                icon: loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.gps_fixed, size: 18),
                label: Text(loading
                    ? l10n.lightPollutionLoadingLabel
                    : l10n.lightPollutionDetectButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObservationStatsCard extends StatelessWidget {
  final List observations;
  const _ObservationStatsCard({required this.observations});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                Text(l10n.lightPollutionObservationCountLabel,
                    style: Theme.of(context).textTheme.labelSmall),
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
                Text(l10n.lightPollutionAverageBortleLabel,
                    style: Theme.of(context).textTheme.labelSmall),
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
                Text(l10n.lightPollutionUrbanObservationLabel,
                    style: Theme.of(context).textTheme.labelSmall),
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
                Text(l10n.lightPollutionDarkSkyObservationLabel,
                    style: Theme.of(context).textTheme.labelSmall),
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
