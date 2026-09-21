import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/observation_provider.dart';
import '../providers/constellation_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/research_report_provider.dart';
import '../models/constellation.dart';
import '../models/observation.dart';
import '../services/share_service.dart';
import '../l10n/generated/app_localizations.dart';

class ResearchReportScreen extends ConsumerStatefulWidget {
  const ResearchReportScreen({super.key});

  @override
  ConsumerState<ResearchReportScreen> createState() =>
      _ResearchReportScreenState();
}

class _ResearchReportScreenState extends ConsumerState<ResearchReportScreen> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: ref.read(researchReportNoteProvider));
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final observations = ref.watch(observationListProvider);
    final constellationsAsync = ref.watch(constellationListProvider);
    final achievements = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.researchReportAppBarTitle),
        centerTitle: true,
      ),
      body: observations.isEmpty
          ? _EmptyState(l10n: l10n)
          : constellationsAsync.when(
              data: (constellations) => _ReportBody(
                l10n: l10n,
                lang: lang,
                observations: observations,
                constellations: constellations,
                achievements: achievements,
                noteController: _noteController,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(child: Text(l10n.researchReportLoadError)),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              l10n.researchReportEmptyTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.researchReportEmptySubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportBody extends ConsumerWidget {
  final AppLocalizations l10n;
  final String lang;
  final List<Observation> observations;
  final List<Constellation> constellations;
  final List<Achievement> achievements;
  final TextEditingController noteController;

  const _ReportBody({
    required this.l10n,
    required this.lang,
    required this.observations,
    required this.constellations,
    required this.achievements,
    required this.noteController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byId = {for (final c in constellations) c.id: c};

    final sorted = [...observations]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final periodStart = sorted.first.timestamp;
    final periodEnd = sorted.last.timestamp;

    final counts = <String, int>{};
    for (final o in observations) {
      counts[o.constellationId] = (counts[o.constellationId] ?? 0) + 1;
    }
    final sortedConstellationIds = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));

    final dark = observations.where((o) => o.bortleScale <= 3).length;
    final suburb = observations.where((o) => o.bortleScale >= 4 && o.bortleScale <= 6).length;
    final city = observations.where((o) => o.bortleScale >= 7).length;

    final unlocked = achievements.where((a) => a.isUnlocked).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionCard(
                  title: l10n.researchReportPeriodLabel,
                  child: Text(
                    l10n.researchReportPeriodValue(
                      _formatDate(periodStart),
                      _formatDate(periodEnd),
                    ),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: l10n.researchReportTotalObservationsLabel,
                  child: Text(
                    l10n.researchReportTotalObservationsValue(observations.length),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: l10n.researchReportConstellationsObservedTitle,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: sortedConstellationIds.map((id) {
                      final c = byId[id];
                      final name = c?.localizedShortName(lang) ?? id;
                      final emoji = c?.emoji ?? '⭐';
                      return Chip(
                        avatar: Text(emoji, style: const TextStyle(fontSize: 14)),
                        label: Text(
                          '$name ${l10n.researchReportConstellationCount(counts[id]!)}',
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: l10n.recordsBortleDistributionTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BortleRow(label: l10n.recordsBortleDark, count: dark, color: Colors.green.shade600),
                      const SizedBox(height: 6),
                      _BortleRow(label: l10n.recordsBortleSuburb, count: suburb, color: Colors.orange.shade500),
                      const SizedBox(height: 6),
                      _BortleRow(label: l10n.recordsBortleCity, count: city, color: Colors.red.shade600),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: l10n.researchReportAchievementsTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.researchReportAchievementsCount(unlocked.length, achievements.length)),
                      if (unlocked.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: unlocked.map<Widget>((a) {
                            return Chip(
                              avatar: Text(a.emoji, style: const TextStyle(fontSize: 14)),
                              label: Text(a.localizedTitle(lang)),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: l10n.researchReportNoteLabel,
                  child: TextField(
                    controller: noteController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: l10n.researchReportNoteHint,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) =>
                        ref.read(researchReportNoteProvider.notifier).update(value),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.ios_share),
                    label: Text(l10n.researchReportShareButton),
                    onPressed: () {
                      final text = _buildReportText(
                        l10n: l10n,
                        lang: lang,
                        periodStart: periodStart,
                        periodEnd: periodEnd,
                        totalObservations: observations.length,
                        sortedConstellationIds: sortedConstellationIds,
                        counts: counts,
                        byId: byId,
                        unlockedCount: unlocked.length,
                        totalAchievements: achievements.length,
                        note: noteController.text,
                      );
                      ShareService.shareResearchReport(text);
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _buildReportText({
    required AppLocalizations l10n,
    required String lang,
    required DateTime periodStart,
    required DateTime periodEnd,
    required int totalObservations,
    required List<String> sortedConstellationIds,
    required Map<String, int> counts,
    required Map<String, Constellation> byId,
    required int unlockedCount,
    required int totalAchievements,
    required String note,
  }) {
    final buffer = StringBuffer()
      ..writeln('🔬 ${l10n.researchReportShareTitle}')
      ..writeln()
      ..writeln('📅 ${l10n.researchReportPeriodLabel}: '
          '${l10n.researchReportPeriodValue(_formatDate(periodStart), _formatDate(periodEnd))}')
      ..writeln('📝 ${l10n.researchReportTotalObservationsLabel}: '
          '${l10n.researchReportTotalObservationsValue(totalObservations)}')
      ..writeln()
      ..writeln('🌌 ${l10n.researchReportConstellationsObservedTitle}:');
    for (final id in sortedConstellationIds) {
      final c = byId[id];
      final name = c?.localizedShortName(lang) ?? id;
      buffer.writeln('  ${c?.emoji ?? '⭐'} $name '
          '${l10n.researchReportConstellationCount(counts[id]!)}');
    }
    buffer
      ..writeln()
      ..writeln('🏆 ${l10n.researchReportAchievementsTitle}: '
          '${l10n.researchReportAchievementsCount(unlockedCount, totalAchievements)}');
    if (note.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('✏️ ${l10n.researchReportNoteLabel}:')
        ..writeln(note.trim());
    }
    buffer
      ..writeln()
      ..write('#ほしぞら大百科 #自由研究');
    return buffer.toString();
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _BortleRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _BortleRow({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const Spacer(),
        Text(
          AppLocalizations.of(context)!.recordsCountTimes(count),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
