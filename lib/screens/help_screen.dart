import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _topics = [
    _HelpTopic(
      emoji: '🔭',
      title: '星座を観測するには？',
      body:
          'ホーム画面の「AR観測」ボタンからカメラを夜空にかざすと、画面上に星座のラインが重なって表示されます。'
          '見つけた星座は「記録を保存」から観測記録として保存でき、図鑑タブに自動で登録されます。',
    ),
    _HelpTopic(
      emoji: '📖',
      title: '図鑑タブの見方',
      body:
          '88星座がカテゴリ別（北天・南天・黄道12星座など）に並びます。まだ観測していない星座はグレー表示、'
          '観測済みの星座はカラーで表示されます。星座をタップすると神話や詳細データを確認できます。',
    ),
    _HelpTopic(
      emoji: '🏙️',
      title: 'シティ・ライト・チャレンジとBortleスケール',
      body:
          '観測記録を追加するときに、その場所の空の明るさを「Bortleスケール（1〜9）」で記録します。'
          '1が最も暗い空、9が最も明るい都市部です。都市部（Bortle 7以上）での観測は難易度が高く、'
          '達成すると「シティハンター」などの称号に近づきます。',
    ),
    _HelpTopic(
      emoji: '⏰',
      title: '星座タイムカプセルとは？',
      body:
          '流星群や月食など、特定の期間だけ現れるレアな観測イベントの記録ページです。'
          'イベント期間中に観測してメッセージを残すと、指定した日付になると自動で解放され、'
          '当時の記録を振り返ることができます。見逃すと次のイベントまで待つ必要があります。',
    ),
    _HelpTopic(
      emoji: '🗺️',
      title: '光害マップ・観測統計',
      body:
          '設定タブの「光害マップ & 観測難易度」から、これまでの観測のBortleスケール分布や'
          '観測のコツを確認できます。自分がどんな環境での観測を得意としているかが分かります。',
    ),
    _HelpTopic(
      emoji: '🏆',
      title: '実績・称号を集めるには？',
      body:
          '観測回数や達成条件に応じて実績が解放され、称号として設定タブのプロフィールに表示されます。'
          '未解放の実績は進捗バーで達成度を確認できます。',
    ),
    _HelpTopic(
      emoji: '🌙',
      title: '夜間赤色モードって何？',
      body:
          '暗闇に慣れた目（暗順応）を守るため、画面全体を赤みがかったフィルターで表示するモードです。'
          '設定タブの「観測設定」からいつでもオン・オフを切り替えられます。',
    ),
    _HelpTopic(
      emoji: '👑',
      title: 'プレミアムでできること',
      body:
          '無料版でも主要な機能は利用できますが、プレミアムにアップグレードすると全88星座とタイムカプセルの'
          '完全解放など、より多くのコンテンツを楽しめます。設定タブから登録できます。',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ヘルプ・使い方'),
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
              '星座コレ！の使い方をトピック別にまとめました。気になる項目をタップして開いてください。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ),
          ..._topics.map((t) => _HelpTile(topic: t)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: ListTile(
                leading: const Icon(Icons.chat_bubble_outline),
                title: const Text('解決しない場合は？'),
                subtitle: const Text('ご意見・不具合報告からお気軽にご連絡ください'),
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
