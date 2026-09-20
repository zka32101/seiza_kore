import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/generated/app_localizations.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  List<_HelpTopic> _topics(AppLocalizations l10n) => [
        _HelpTopic(emoji: '🔭', title: l10n.helpTopic1Title, body: l10n.helpTopic1Body),
        _HelpTopic(emoji: '📖', title: l10n.helpTopic2Title, body: l10n.helpTopic2Body),
        _HelpTopic(emoji: '🏙️', title: l10n.helpTopic3Title, body: l10n.helpTopic3Body),
        _HelpTopic(emoji: '⏰', title: l10n.helpTopic4Title, body: l10n.helpTopic4Body),
        _HelpTopic(emoji: '🗺️', title: l10n.helpTopic5Title, body: l10n.helpTopic5Body),
        _HelpTopic(emoji: '🏆', title: l10n.helpTopic6Title, body: l10n.helpTopic6Body),
        _HelpTopic(emoji: '🌙', title: l10n.helpTopic7Title, body: l10n.helpTopic7Body),
        _HelpTopic(emoji: '👑', title: l10n.helpTopic8Title, body: l10n.helpTopic8Body),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helpScreenTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              l10n.helpIntro,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ),
          ..._topics(l10n).map((t) => _HelpTile(topic: t)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: ListTile(
                leading: const Icon(Icons.chat_bubble_outline),
                title: Text(l10n.helpContactTitle),
                subtitle: Text(l10n.helpContactSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/feedback'),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _HelpTopic {
  final String emoji;
  final String title;
  final String body;

  const _HelpTopic({
    required this.emoji,
    required this.title,
    required this.body,
  });
}

class _HelpTile extends StatelessWidget {
  final _HelpTopic topic;
  const _HelpTile({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: Text(topic.emoji, style: const TextStyle(fontSize: 22)),
        title: Text(topic.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(topic.body, style: const TextStyle(height: 1.6)),
        ],
      ),
    );
  }
}
