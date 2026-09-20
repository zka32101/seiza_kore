import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/observation_provider.dart';
import '../providers/constellation_provider.dart';
import '../services/ranking_service.dart';
import '../l10n/generated/app_localizations.dart';

/// 全国の観測者と観測数を競うグローバルランキング画面。
/// 画面表示時に、端末のローカル記録をFirestoreへ同期してから
/// ランキングを取得する。
class RankingScreen extends ConsumerStatefulWidget {
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen> {
  late Future<_RankingData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadRanking();
  }

  Future<_RankingData> _loadRanking() async {
    final user = await RankingService.ensureSignedIn();

    final observations = ref.read(observationListProvider);
    final unlockedIds = ref.read(unlockedIdsProvider);

    await RankingService.syncMyStats(
      uid: user.uid,
      displayName: user.displayName,
      totalObservations: observations.length,
      unlockedConstellations: unlockedIds.length,
    );

    final entries = await RankingService.fetchTopByObservations();
    return _RankingData(myUid: user.uid, entries: entries);
  }

  Future<void> _refresh() async {
    setState(() => _future = _loadRanking());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.rankingTitle),
        centerTitle: true,
      ),
      body: FutureBuilder<_RankingData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(l10n.rankingLoadError),
                    const SizedBox(height: 4),
                    Text(
                      '${snapshot.error}',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: _refresh, child: Text(l10n.rankingRetry)),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          if (data.entries.isEmpty) {
            return Center(child: Text(l10n.rankingEmptyMessage));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: data.entries.length,
              itemBuilder: (context, index) {
                final entry = data.entries[index];
                final isMe = entry.uid == data.myUid;
                return _RankingTile(rank: index + 1, entry: entry, isMe: isMe);
              },
            ),
          );
        },
      ),
    );
  }
}

class _RankingData {
  final String myUid;
  final List<RankingEntry> entries;
  const _RankingData({required this.myUid, required this.entries});
}

class _RankingTile extends StatelessWidget {
  final int rank;
  final RankingEntry entry;
  final bool isMe;

  const _RankingTile({required this.rank, required this.entry, required this.isMe});

  String _medal(AppLocalizations l10n) => switch (rank) {
        1 => '🥇',
        2 => '🥈',
        3 => '🥉',
        _ => l10n.rankingPositionLabel(rank),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isMe
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: isMe
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5)
            : null,
      ),
      child: ListTile(
        leading: SizedBox(
          width: 44,
          child: Text(
            _medal(l10n),
            style: TextStyle(fontSize: rank <= 3 ? 22 : 15, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        title: Text(
          entry.displayName,
          style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.normal),
        ),
        subtitle: Text(l10n.rankingUnlockedLabel(entry.unlockedConstellations)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.totalObservations}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(l10n.rankingTimesLabel, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
