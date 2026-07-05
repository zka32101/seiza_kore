# 星座コレ！ Release Notes

## v1.1.0 (Phase 22 - July 2026)

### 🌟 新機能

#### Phase 18: Light-year Time Travel
- **光年の時間旅行**: 各星座の主要星の光年距離を表示
- 観測時点から計算した「光が出発した年」を表示
- 88星座すべてに対応した光年データベース
- Ultra City Master achievement（Bortle 8-9で20回観測）

#### Phase 19: Star Data Expansion
- **88星座完全対応**: すべての星座に光年情報を追加
- 光年距離: 4.4光年（Alpha Centauri）～ 2600+光年（Deneb）
- 北天・南天・黄道12星座を網羅

#### Phase 20: Firebase Integration
- **クラウド認証**: ゲスト・メール登録対応
- **Firestore スキーマ**: users, observations, achievements
- **データ同期**: 観測記録の永続化とマルチデバイス対応

#### Phase 21a: Constellation Time Capsule
- **星座タイムカプセル**: 観測を未来に保存
- 指定日付に自動解放
- 個人メッセージ と Bortle スケール記録

#### Phase 21b: Light Pollution Map
- **光害マップ**: Bortle スケール1-9の可視化
- **観測統計**: ユーザーの平均Bortle、都市観測回数、暗空観測回数
- **難易度分布**: 星座の難易度別グループ化
- **観測のコツ**: 各環境での観測ガイド

#### Phase 21c: Star Naming System
- **星座の命名**: 発見した星座に自分で名前をつける
- **命名理由**: 各命名の背景を記録
- **管理UI**: 編集・削除機能付き

### 🔧 技術改善

- Flutter 3.44.4 + Dart 3.12.2
- Riverpod 2.4.0 状態管理
- Material 3 UI フレームワーク
- Firebase Core + Auth + Firestore 統合
- Intl パッケージで多言語対応準備

### 📊 成果指標

| 項目 | 数値 |
|------|------|
| 実装星座 | 88個（100%） |
| 光年データ | 88個の主要星 |
| アチーブメント | 9個（新規1個） |
| スクリーン | 12個（新規3個） |
| コード行数（新規） | ~2,000行 |

### 🐛 既知の制限

- Firebase プロジェクト設定が必要（API キー設定）
- Web 版のみリリース（iOS/Android は別途ビルド）
- オフラインモードは基本機能のみ対応

### 🎯 次のフェーズ（v1.2 候補）

- AR観測の実装と改善
- プレミアム課金機能（RevenueCat）
- ソーシャル機能（フレンド・共有）
- プッシュ通知（流星群・月食アラート）
- 多言語対応（英語・中国語）

---

**Release Date**: July 2026  
**Developed with**: Flutter + Firebase + Riverpod
