import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/settings_provider.dart';
import '../providers/constellation_provider.dart';
import '../providers/observation_provider.dart';
import '../providers/achievement_provider.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final unlockedCount = ref.watch(unlockedIdsProvider).length;
    final obsCount = ref.watch(observationListProvider).length;
    final userTitle = ref.watch(userTitleProvider);
    final achievements = ref.watch(achievementsProvider);
    final unlockedAchCount = ref.watch(unlockedAchievementCountProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile card
          _ProfileCard(
            isGuest: settings.isGuest,
            isPremium: settings.isPremium,
            userTitle: userTitle,
          ),

          // Stats
          GestureDetector(
            onTap: () => context.push('/stats'),
            child: _StatsCard(unlockedCount: unlockedCount, obsCount: obsCount),
          ),

          // Achievements
          _AchievementsCard(
            achievements: achievements,
            unlockedCount: unlockedAchCount,
          ),

          // Premium
          if (!settings.isPremium)
            _PremiumBanner(),

          // Observation settings
          _SettingSection(
            title: '観測設定',
            children: [
              SwitchListTile(
                title: const Text('夜間赤色モード'),
                subtitle: const Text('目の暗順応を保護するフィルター'),
                secondary: Icon(
                  Icons.remove_red_eye,
                  color: settings.nightModeEnabled
                      ? Colors.red
                      : Colors.grey,
                ),
                value: settings.nightModeEnabled,
                onChanged: (v) => notifier.setNightMode(v),
              ),
            ],
          ),

          // Privacy settings
          _SettingSection(
            title: 'プライバシー',
            children: [
              SwitchListTile(
                title: const Text('位置情報共有'),
                subtitle: const Text('都道府県レベルのみ（個人特定不可）'),
                secondary: const Icon(Icons.location_on),
                value: settings.locationSharingEnabled,
                onChanged: (v) => notifier.setLocationSharing(v),
              ),
              SwitchListTile(
                title: const Text('夜空Connect参加'),
                subtitle: const Text('今この星座を見ているユーザー数を表示'),
                secondary: const Icon(Icons.people),
                value: settings.nightSkyConnectEnabled,
                onChanged: settings.locationSharingEnabled
                    ? (v) => notifier.setNightSkyConnect(v)
                    : null,
              ),
              if (!settings.locationSharingEnabled)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    '※ 夜空Connectには位置情報共有のONが必要です',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),

          // Notifications
          _SettingSection(
            title: '通知',
            children: [
              SwitchListTile(
                title: const Text('タイムカプセルイベント'),
                subtitle: const Text('流星群などのイベント開始時に通知'),
                secondary: const Icon(Icons.notifications),
                value: settings.timecapsuleNotificationsEnabled,
                onChanged: (v) => notifier.setTimecapsuleNotifications(v),
              ),
              SwitchListTile(
                title: const Text('新星座解放通知'),
                subtitle: const Text('新しい星座を発見したときに通知'),
                secondary: const Icon(Icons.stars),
                value: settings.unlockedNotificationsEnabled,
                onChanged: (v) => notifier.setUnlockedNotifications(v),
              ),
            ],
          ),

          // Data management
          _SettingSection(
            title: 'データ管理',
            children: [
              ListTile(
                leading: const Icon(Icons.file_download_outlined),
                title: const Text('観測データをエクスポート'),
                subtitle: const Text('JSON形式でダウンロード（バックアップ用）'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('バックアップ機能は後で実装')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'すべてのデータを削除',
                  style: TextStyle(color: Colors.red),
                ),
                subtitle: const Text('図鑑・観測記録すべてが削除されます'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('すべてのデータを削除？'),
                      content: const Text(
                        'この操作は取り消せません。\n図鑑、観測記録、お気に入り、すべてのデータが削除されます。',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('キャンセル'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            final prefs =
                                await SharedPreferences.getInstance();
                            await prefs.clear();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('すべてのデータが削除されました'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: const Text(
                            '削除',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          // Support
          _SettingSection(
            title: 'サポート',
            children: [
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('ヘルプ・使い方'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('利用規約'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('プライバシーポリシー'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.bug_report_outlined),
                title: const Text('不具合報告'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),

          // Account actions
          _SettingSection(
            title: 'その他',
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('アプリバージョン'),
                trailing: Text(
                  'v1.0.0',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.orange.shade700),
                title: Text(
                  'ログアウト',
                  style: TextStyle(color: Colors.orange.shade700),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('ログアウト'),
                      content: const Text('ゲストモードのデータは失われます。よろしいですか？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('キャンセル'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.go('/login');
                          },
                          child: Text(
                            'ログアウト',
                            style: TextStyle(color: Colors.orange.shade700),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final bool isGuest;
  final bool isPremium;
  final String userTitle;
  const _ProfileCard({
    required this.isGuest,
    required this.isPremium,
    required this.userTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                isGuest ? '👤' : '⭐',
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isGuest ? 'ゲストユーザー' : '登録ユーザー',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      userTitle,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (isGuest)
                    Text(
                      'アカウント登録でデータを保存',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  if (isPremium)
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber.shade600, size: 14),
                        const SizedBox(width: 4),
                        const Text(
                          'プレミアム会員',
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (isGuest)
              ElevatedButton(
                onPressed: () {},
                child: const Text('登録'),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final int unlockedCount;
  final int obsCount;
  const _StatsCard({required this.unlockedCount, required this.obsCount});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
            _StatItem(
              label: '星座コレクション',
              value: '$unlockedCount/88',
              icon: Icons.menu_book,
              color: Theme.of(context).colorScheme.primary,
            ),
            Container(width: 1, height: 48, color: Colors.grey.shade300),
            _StatItem(
              label: '観測記録',
              value: '$obsCount件',
              icon: Icons.history,
              color: Colors.teal,
            ),
            Container(width: 1, height: 48, color: Colors.grey.shade300),
            _StatItem(
              label: '観測難易度',
              value: '★★★',
              icon: Icons.emoji_events,
              color: Colors.amber.shade700,
            ),
          ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Icon(
              Icons.info_outline,
              size: 18,
              color: Theme.of(context).colorScheme.primary.withAlpha(100),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _AchievementsCard extends StatelessWidget {
  final List<Achievement> achievements;
  final int unlockedCount;

  const _AchievementsCard({
    required this.achievements,
    required this.unlockedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Row(
              children: [
                Text(
                  '実績・称号',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$unlockedCount/${achievements.length}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: achievements.map((a) => _AchievementTile(a: a)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement a;
  const _AchievementTile({required this.a});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: a.isUnlocked
            ? colorScheme.primaryContainer
            : Colors.grey.shade200,
        child: Text(
          a.isUnlocked ? a.emoji : '🔒',
          style: const TextStyle(fontSize: 18),
        ),
      ),
      title: Text(
        a.title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: a.isUnlocked ? null : Colors.grey.shade500,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            a.description,
            style: TextStyle(
              fontSize: 12,
              color: a.isUnlocked ? null : Colors.grey.shade400,
            ),
          ),
          if (!a.isUnlocked) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: a.progress / a.goal,
                      minHeight: 4,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${a.progress}/${a.goal}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      trailing: a.isUnlocked
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : null,
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.hardEdge,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade700, Colors.purple.shade600],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text('👑', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'プレミアムにアップグレード',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const Text(
                    '全88星座 + タイムカプセル完全解放',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: const Text('¥600'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}
