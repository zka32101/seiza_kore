import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/observation_provider.dart';
import '../providers/constellation_provider.dart';
import '../providers/ranking_group_provider.dart';
import '../services/ranking_service.dart';
import '../l10n/generated/app_localizations.dart';

/// フレンド/クラス限定のグループコードで観測数を競うランキング画面。
/// コードを知っている人同士だけが参加できるため、不特定多数と比較される
/// グローバル公開ランキングと異なり、児童向けアプリとして安全性に配慮している。
class RankingScreen extends ConsumerStatefulWidget {
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen> {
  Future<_RankingData>? _future;
  bool _isCreatingOrJoining = false;
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<_RankingData> _loadRanking(String groupCode) async {
    final user = await RankingService.ensureSignedIn();

    final observations = ref.read(observationListProvider);
    final unlockedIds = ref.read(unlockedIdsProvider);

    await RankingService.syncMyStats(
      uid: user.uid,
      displayName: user.displayName,
      totalObservations: observations.length,
      unlockedConstellations: unlockedIds.length,
      groupCode: groupCode,
    );

    final entries =
        await RankingService.fetchTopByObservations(groupCode: groupCode);
    return _RankingData(myUid: user.uid, entries: entries);
  }

  Future<void> _refresh(String groupCode) async {
    final future = _loadRanking(groupCode);
    setState(() => _future = future);
    await future;
  }

  Future<void> _createGroup() async {
    setState(() => _isCreatingOrJoining = true);
    final code = RankingService.generateGroupCode();
    await ref.read(rankingGroupProvider.notifier).setGroupCode(code);
    if (mounted) {
      setState(() => _isCreatingOrJoining = false);
      await _refresh(code);
    }
  }

  Future<void> _joinGroup() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;
    setState(() => _isCreatingOrJoining = true);
    await ref.read(rankingGroupProvider.notifier).setGroupCode(code);
    if (mounted) {
      setState(() => _isCreatingOrJoining = false);
      await _refresh(code);
    }
  }

  Future<void> _leaveGroup() async {
    await ref.read(rankingGroupProvider.notifier).setGroupCode(null);
    setState(() => _future = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final groupCode = ref.watch(rankingGroupProvider);

    if (groupCode == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.rankingTitle), centerTitle: true),
        body: _JoinOrCreateView(
          isBusy: _isCreatingOrJoining,
          codeController: _codeController,
          onCreate: _createGroup,
          onJoin: _joinGroup,
        ),
      );
    }

    _future ??= _loadRanking(groupCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.rankingTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.rankingLeaveGroupButton,
            onPressed: _leaveGroup,
          ),
        ],
      ),
      body: Column(
        children: [
          _GroupCodeBanner(groupCode: groupCode),
          Expanded(
            child: FutureBuilder<_RankingData>(
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
                          FilledButton(
                            onPressed: () => _refresh(groupCode),
                            child: Text(l10n.rankingRetry),
                          ),
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
                  onRefresh: () => _refresh(groupCode),
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
          ),
        ],
      ),
    );
  }
}

class _JoinOrCreateView extends StatelessWidget {
  final bool isBusy;
  final TextEditingController codeController;
  final VoidCallback onCreate;
  final VoidCallback onJoin;

  const _JoinOrCreateView({
    required this.isBusy,
    required this.codeController,
    required this.onCreate,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('👥', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              l10n.rankingJoinIntroTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.rankingJoinIntroSubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: Text(l10n.rankingCreateGroupButton),
                onPressed: isBusy ? null : onCreate,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(l10n.commonOr, style: TextStyle(color: Colors.grey.shade500)),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: l10n.rankingCodeFieldLabel,
                border: const OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isBusy ? null : onJoin,
                child: Text(l10n.rankingJoinGroupButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCodeBanner extends StatelessWidget {
  final String groupCode;
  const _GroupCodeBanner({required this.groupCode});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.rankingGroupCodeLabel(groupCode),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            tooltip: l10n.rankingCopyCodeTooltip,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: groupCode));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.rankingCodeCopied)),
              );
            },
          ),
        ],
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
