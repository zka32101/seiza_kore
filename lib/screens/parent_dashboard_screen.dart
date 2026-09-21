import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/observation_provider.dart';
import '../providers/constellation_provider.dart';
import '../providers/achievement_provider.dart';
import '../models/observation.dart';
import '../l10n/generated/app_localizations.dart';

/// 保護者向けの学習サマリー画面。子供の観測記録・進捗・実績を
/// 読み取り専用でまとめて確認できる（設定変更はできない）。
class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final observations = ref.watch(observationListProvider);
    final unlockedCount = ref.watch(unlockedIdsProvider).length;
    final weeklyCount = ref.watch(weeklyObservationCountProvider);
    final earnedCount = ref.watch(unlockedAchievementCountProvider);
    final totalAchievements = ref.watch(achievementsProvider).length;
    final userTitleId = ref.watch(userTitleProvider);
    final userTitle = userTitleLabel(userTitleId, lang);
    final recent = observations.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.parentDashboardTitle),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.family_restroom, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.parentDashboardIntro,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: l10n.parentDashboardTotalObservations,
                  value: '${observations.length}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: l10n.parentDashboardWeeklyObservations,
                  value: '$weeklyCount',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: l10n.parentDashboardCollectionProgress,
                  value: '$unlockedCount/88',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: l10n.parentDashboardAchievements,
                  value: '$earnedCount/$totalAchievements',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_outlined, color: Colors.amber),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.parentDashboardCurrentTitleLabel,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          userTitle,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.parentDashboardRecentActivityTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                l10n.parentDashboardNoActivity,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          else
            ...recent.map((o) => _RecentActivityTile(observation: o)),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityTile extends ConsumerWidget {
  final Observation observation;
  const _RecentActivityTile({required this.observation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final constellationAsync =
        ref.watch(constellationByIdProvider(observation.constellationId));
    final name = constellationAsync.when(
      data: (c) => c == null
          ? observation.constellationId
          : (lang == 'en' ? c.nameEn : c.nameJa),
      loading: () => '...',
      error: (_, __) => observation.constellationId,
    );
    final date =
        '${observation.timestamp.month}/${observation.timestamp.day}';

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: Text(
          constellationAsync.when(
            data: (c) => c?.emoji ?? '⭐',
            loading: () => '⭐',
            error: (_, __) => '⭐',
          ),
          style: const TextStyle(fontSize: 20),
        ),
        title: Text(name),
        subtitle: Text('$date  ${observation.locationName}'),
      ),
    );
  }
}
