import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/generated/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/constellation_provider.dart';
import '../providers/observation_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/update_notes_provider.dart';
import '../data/update_notes_data.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final unlockedCount = ref.watch(unlockedIdsProvider).length;
    final obsCount = ref.watch(observationListProvider).length;
    final userTitle = ref.watch(userTitleProvider);
    final achievements = ref.watch(achievementsProvider);
    final unlockedAchCount = ref.watch(unlockedAchievementCountProvider);
    final hasUnseenUpdate = ref.watch(hasUnseenUpdateProvider);
    final locale = ref.watch(localeProvider);

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

          // Light Pollution Map
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.public, color: Colors.indigo),
                title: Text(l10n.settingsLightPollutionTitle),
                subtitle: Text(l10n.settingsLightPollutionSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/light-pollution-map'),
              ),
            ),
          ),

          // Achievements
          _AchievementsCard(
            achievements: achievements,
            unlockedCount: unlockedAchCount,
            title: l10n.settingsAchievementsTitle,
          ),

          // Premium
          if (!settings.isPremium)
            _PremiumBanner(
              title: l10n.settingsPremiumUpgradeTitle,
              subtitle: l10n.settingsPremiumUpgradeSubtitle,
            ),

          // Display settings (language)
          _SettingSection(
            title: l10n.settingsSectionDisplay,
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.settingsLanguageTitle),
                subtitle: Text(
                  locale == null
                      ? l10n.settingsLanguageSystem
                      : (locale.languageCode == 'ja'
                          ? l10n.settingsLanguageJapanese
                          : l10n.settingsLanguageEnglish),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguagePicker(context, ref, l10n, locale),
              ),
            ],
          ),

          // Observation settings
          _SettingSection(
            title: l10n.settingsSectionObservation,
            children: [
              SwitchListTile(
                title: Text(l10n.settingsNightModeTitle),
                subtitle: Text(l10n.settingsNightModeSubtitle),
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
            title: l10n.settingsSectionPrivacy,
            children: [
              SwitchListTile(
                title: Text(l10n.settingsLocationSharingTitle),
                subtitle: Text(l10n.settingsLocationSharingSubtitle),
                secondary: const Icon(Icons.location_on),
                value: settings.locationSharingEnabled,
                onChanged: (v) => notifier.setLocationSharing(v),
              ),
              SwitchListTile(
                title: Text(l10n.settingsNightSkyConnectTitle),
                subtitle: Text(l10n.settingsNightSkyConnectSubtitle),
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
                    l10n.settingsNightSkyConnectWarning,
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
            title: l10n.settingsSectionNotifications,
            children: [
              SwitchListTile(
                title: Text(l10n.settingsTimecapsuleNotifTitle),
                subtitle: Text(l10n.settingsTimecapsuleNotifSubtitle),
                secondary: const Icon(Icons.notifications),
                value: settings.timecapsuleNotificationsEnabled,
                onChanged: (v) => notifier.setTimecapsuleNotifications(v),
              ),
              SwitchListTile(
                title: Text(l10n.settingsUnlockedNotifTitle),
                subtitle: Text(l10n.settingsUnlockedNotifSubtitle),
                secondary: const Icon(Icons.stars),
                value: settings.unlockedNotificationsEnabled,
                onChanged: (v) => notifier.setUnlockedNotifications(v),
              ),
            ],
          ),

          // Data management
          _SettingSection(
            title: l10n.settingsSectionDataManagement,
            children: [
              ListTile(
                leading: const Icon(Icons.file_download_outlined),
                title: Text(l10n.settingsExportTitle),
                subtitle: Text(l10n.settingsExportSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.settingsExportSnack)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(
                  l10n.settingsDeleteAllTitle,
                  style: const TextStyle(color: Colors.red),
                ),
                subtitle: Text(l10n.settingsDeleteAllSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(l10n.settingsDeleteAllDialogTitle),
                      content: Text(l10n.settingsDeleteAllDialogContent),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.commonCancel),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            final prefs =
                                await SharedPreferences.getInstance();
                            await prefs.clear();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.settingsDeleteAllDone),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Text(
                            l10n.commonDelete,
                            style: const TextStyle(color: Colors.red),
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
            title: l10n.settingsSectionSupport,
            children: [
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: Text(l10n.settingsHelpTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/help'),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(l10n.loginTerms),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l10n.loginPrivacy),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.bug_report_outlined),
                title: Text(l10n.settingsFeedbackTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/feedback'),
              ),
            ],
          ),

          // Account actions
          _SettingSection(
            title: l10n.settingsSectionOther,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.settingsUpdateNotesTitle),
                subtitle: Text('v$currentAppVersion'),
                trailing: hasUnseenUpdate
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              l10n.settingsUpdateNotesNew,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      )
                    : const Icon(Icons.chevron_right),
                onTap: () => context.push('/update-notes'),
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.orange.shade700),
                title: Text(
                  l10n.settingsLogoutTitle,
                  style: TextStyle(color: Colors.orange.shade700),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(l10n.settingsLogoutTitle),
                      content: Text(l10n.settingsLogoutDialogContent),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.commonCancel),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.go('/login');
                          },
                          child: Text(
                            l10n.settingsLogoutTitle,
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

  void _showLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Locale? current,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Locale?>(
              title: Text(l10n.settingsLanguageSystem),
              value: null,
              groupValue: current,
              onChanged: (v) {
                ref.read(localeProvider.notifier).setLocale(v);
                Navigator.pop(context);
              },
            ),
            RadioListTile<Locale?>(
              title: Text(l10n.settingsLanguageJapanese),
              value: const Locale('ja'),
              groupValue: current,
              onChanged: (v) {
                ref.read(localeProvider.notifier).setLocale(v);
                Navigator.pop(context);
              },
            ),
            RadioListTile<Locale?>(
              title: Text(l10n.settingsLanguageEnglish),
              value: const Locale('en'),
              groupValue: current,
              onChanged: (v) {
                ref.read(localeProvider.notifier).setLocale(v);
                Navigator.pop(context);
              },
            ),
          ],
        ),
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
    final l10n = AppLocalizations.of(context)!;
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
                    isGuest ? l10n.settingsGuestUser : l10n.settingsRegisteredUser,
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
                      l10n.settingsGuestHint,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  if (isPremium)
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber.shade600, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          l10n.settingsPremiumMember,
                          style: const TextStyle(
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
                child: Text(l10n.settingsRegisterButton),
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
    final l10n = AppLocalizations.of(context)!;
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
              label: l10n.settingsStatCollection,
              value: '$unlockedCount/88',
              icon: Icons.menu_book,
              color: Theme.of(context).colorScheme.primary,
            ),
            Container(width: 1, height: 48, color: Colors.grey.shade300),
            _StatItem(
              label: l10n.settingsStatObservations,
              value: l10n.settingsStatObservationsValue(obsCount),
              icon: Icons.history,
              color: Colors.teal,
            ),
            Container(width: 1, height: 48, color: Colors.grey.shade300),
            _StatItem(
              label: l10n.settingsStatDifficulty,
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
  final String title;

  const _AchievementsCard({
    required this.achievements,
    required this.unlockedCount,
    required this.title,
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
                  title,
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
  final String title;
  final String subtitle;
  const _PremiumBanner({required this.title, required this.subtitle});

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
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
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
