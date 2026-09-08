# 星座・理科コレ

**小学生向けの楽しい理科学習アプリ** 🌟📚

## 概要

「星座・理科コレ」は小学1年生から6年生を対象とした、ゲーム感覚で理科を学べるFlutterアプリです。星座学習、自然現象、物の性質など、複合的な学習体験を提供します。

## ✨ 主な機能

### 📚 学習ガイド
- 複数の理科概念（星座、季節、天体、自然現象等）
- 学年別の段階的な説明
- ふりがな対応で読みやすい
- 進捗追跡と完了バッジ

### 🎮 ステージシステム
- 複数ステージで学年別に展開
- 各ステージ3～5問で短時間クリア可能
- 選択肢のランダム配置

### 🎨 学習体験
- ふりがな（ルビ）対応で低学年も安心
- VFX（ビジュアルエフェクト）で達成感UP
- サウンドエフェクト付き
- キャラクター育成システム

### 🏆 進捗管理
- バッジ・アチーブメントシステム
- ランキング機能
- 日替わりチャレンジ
- 紹介システムでコイン獲得

## 🏗️ アーキテクチャ

### 技術スタック
- **フレームワーク**: Flutter 3.11.5+
- **状態管理**: Riverpod (StateNotifier, FutureProvider)
- **永続化**: SharedPreferences + Firebase
- **認証**: Firebase Authentication
- **言語**: Dart

### 層構造
```
Presentation (Screens & Widgets)
         ↓
State Management (Providers)
         ↓
Data Layer (Models & Repositories)
```

## 📦 ビルド・デプロイ

### 🚀 自動ビルド（GitHub Actions）

このプロジェクトは GitHub Actions による自動ビルド・デプロイパイプラインに対応しています。

**詳細ガイド**: [`yourwish/docs/build-ci-cd-guide.md`](https://github.com/zka32101/yourwish/blob/master/docs/build-ci-cd-guide.md)

#### トリガー条件
- ✅ `claude/**` ブランチへの push
- ✅ Pull Request (main/develop)
- ✅ 手動実行 (workflow_dispatch)
- ✅ 週1回スケジュール実行

#### 自動実行内容
1. **コード分析・テスト** - `flutter analyze`, `flutter test`
2. **Android ビルド** - APK/AAB 生成
3. **iOS ビルド** - IPA 生成 (unsigned)
4. **ビルドサマリー** - 結果集計

#### ワークフローファイル
- `.github/workflows/build-apk.yml` - 基本ビルド
- テンプレート: [`yourwish/.github/workflows/build-template.yml`](https://github.com/zka32101/yourwish/blob/master/.github/workflows/build-template.yml)

---

### 💻 ローカルビルド

#### 前提条件
- Flutter 3.11.5以上
- Dart 3.1.0以上
- Android SDK (APIレベル21以上)
- Java 17

#### セットアップ

```bash
# リポジトリをクローン
git clone https://github.com/zka32101/seiza_kore.git
cd seiza_kore

# 依存パッケージをインストール
flutter pub get

# コード生成実行（Firebase等）
flutter pub run build_runner build
```

#### 実行

```bash
# デバッグモード
flutter run

# リリースビルド
flutter build apk --release
flutter build appbundle --release
```

---

### 📚 SessionStart Hook（自動初期化）

Claude Code セッション起動時に自動的に以下を実行：
- `flutter pub get` - 依存関係インストール
- `flutter analyze` - コード分析

設定ファイル: `.claude/hooks/session-start.sh`

---

### 🧪 build-and-test スキル（6観点テスト）

```bash
/build-and-test seiza_kore
```

**テスト観点**:
1. 起動テスト
2. 接続テスト
3. 課金画面
4. 認証フロー
5. 広告表示
6. クラッシュ検出

## 📊 プロジェクト構造

```
lib/
├── models/           # データモデル
├── providers/        # Riverpod状態管理
├── screens/          # 画面UI
├── widgets/          # 再利用ウィジェット
├── data/             # 定数データ（ステージ、ガイド等）
├── theme/            # テーマ・スタイリング
└── main.dart         # アプリケーション起点
```

## 🧪 テスト

```bash
# ユニットテスト
flutter test

# テストカバレッジ
flutter test --coverage
```

## 📱 デバイスサポート

| OS | 最小バージョン | 推奨バージョン |
|----|--------------|------------|
| Android | 5.1 (API 22) | 12.0+ (API 31+) |
| iOS | 11.0+ | 15.0+ |

## 🚀 リリース情報

- **バージョン**: 1.0.0
- **ビルド番号**: 1
- **ステータス**: 開発中

## 📄 ライセンス

© 2026 [org-zka32101]. All rights reserved.

## 👥 コントリビューション

バグ報告・フィーチャーリクエストはGitHub Issuesへ。

## 📞 サポート

問題が発生した場合：
1. [Issues](https://github.com/zka32101/seiza_kore/issues)を確認
2. デバッグログを `flutter logs` で確認
3. Issueを作成する場合は詳細な再現手順を記載
