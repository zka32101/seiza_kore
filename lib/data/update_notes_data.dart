// アプリ内の「更新履歴」画面に表示するデータ。
// リリースのたびに新しい UpdateNote を先頭に追加していく。
class UpdateNote {
  final String version;
  final String date;
  final String dateEn;
  final List<String> highlights;
  final List<String> highlightsEn;

  const UpdateNote({
    required this.version,
    required this.date,
    required this.dateEn,
    required this.highlights,
    required this.highlightsEn,
  });

  String localizedDate(String languageCode) => languageCode == 'en' ? dateEn : date;

  List<String> localizedHighlights(String languageCode) =>
      languageCode == 'en' ? highlightsEn : highlights;
}

const currentAppVersion = '1.1.0';

const List<UpdateNote> updateNotes = [
  UpdateNote(
    version: '1.1.0',
    date: '2026年7月',
    dateEn: 'July 2026',
    highlights: [
      '🌟 光年の時間旅行: 星座の主要星までの距離と「光が出発した年」を表示',
      '⏰ 星座タイムカプセル: 観測を未来の日付に保存し、当日に自動解放',
      '🗺️ 光害マップ: Bortleスケールの可視化と観測統計・観測のコツを追加',
      '✏️ 星座の命名: 発見した星座に自分だけの名前と理由を記録',
      '☁️ クラウド連携: ゲスト/メール登録・観測記録の同期に対応',
    ],
    highlightsEn: [
      '🌟 Light-Year Time Travel: see the distance to a constellation\'s main star and the year its light left',
      '⏰ Constellation Time Capsule: save an observation for a future date, unlocked automatically on the day',
      '🗺️ Light Pollution Map: visualize the Bortle scale plus observation stats and tips',
      '✏️ Constellation naming: give constellations you discover your own name and reason',
      '☁️ Cloud sync: guest/email sign-up and observation record syncing',
    ],
  ),
  UpdateNote(
    version: '1.0.0',
    date: '2026年6月',
    dateEn: 'June 2026',
    highlights: [
      '🔭 88星座図鑑と観測記録機能をリリース',
      '🏙️ シティ・ライト・チャレンジ: Bortleスケール別の難易度に対応',
      '🏆 実績・称号システムを追加',
    ],
    highlightsEn: [
      '🔭 Launched the 88-constellation catalog and observation records',
      '🏙️ City Light Challenge: difficulty based on the Bortle scale',
      '🏆 Added an achievements and titles system',
    ],
  ),
];
