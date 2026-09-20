import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/achievement_provider.dart';
import '../services/share_service.dart';
import '../l10n/generated/app_localizations.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final allAchievements = ref.watch(achievementsProvider);
    final userTitleId = ref.watch(userTitleProvider);
    final userTitle = userTitleLabel(userTitleId, lang);
    final unlockedCount = ref.watch(unlockedAchievementCountProvider);
    final total = allAchievements.length;

    final unlocked = allAchievements.where((a) => a.isUnlocked).toList();
    final locked = allAchievements.where((a) => !a.isUnlocked).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.achievementsTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard_outlined),
            tooltip: l10n.achievementsRankingTooltip,
            onPressed: () => context.push('/ranking'),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ユーザー称号カード
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        l10n.achievementsYourTitleLabel,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userTitle,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$unlockedCount',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Text(
                            ' / $total',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.achievementsUnlockedLabel,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: total == 0 ? 0 : unlockedCount / total,
                          minHeight: 8,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withAlpha(50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 解放済み
          if (unlocked.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  l10n.achievementsUnlockedSection(unlocked.length),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _AchievementTile(
                  achievement: unlocked[i],
                  isUnlocked: true,
                ),
                childCount: unlocked.length,
              ),
            ),
          ],

          // 未解放
          if (locked.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  l10n.achievementsLockedSection(locked.length),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _AchievementTile(
                  achievement: locked[i],
                  isUnlocked: false,
                ),
                childCount: locked.length,
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;

  const _AchievementTile({
    required this.achievement,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final progress = achievement.progress / achievement.goal;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        color: isUnlocked
            ? null
            : Theme.of(context).colorScheme.surfaceVariant.withAlpha(100),
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.grey.shade200,
            ),
            child: Center(
              child: Text(
                isUnlocked ? achievement.emoji : '🔒',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          title: Text(
            achievement.localizedTitle(lang),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isUnlocked
                      ? null
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                achievement.localizedDescription(lang),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              if (!isUnlocked && achievement.goal > 1) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: Colors.grey.shade300,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${achievement.progress}/${achievement.goal}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ],
          ),
          trailing: isUnlocked
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 20),
                      tooltip: l10n.achievementsShareTooltip,
                      onPressed: () => ShareService.shareAchievement(
                        title: achievement.localizedTitle(lang),
                        description: achievement.localizedDescription(lang),
                        emoji: achievement.emoji,
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }
}
