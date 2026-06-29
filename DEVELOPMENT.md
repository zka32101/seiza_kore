# 星座コレ！ 開発ガイド

## プロジェクト構造

```
lib/
  main.dart              # エントリーポイント (Riverpod + GoRouter)
  app.dart               # アプリケーション設定、ルーティング
  
  screens/
    splash_screen.dart   # スプラッシュ画面（3秒自動遷移）
    login_screen.dart    # ログイン/ゲスト選択画面
    home_screen.dart     # ホーム画面（タブナビゲーション）
  
  widgets/
    observation_tab.dart # 観測タブ（本日の推奨、AR観測ボタン、最近の観測）
    catalog_tab.dart     # 図鑑タブ（88星座グリッド、カテゴリ分類）
    records_tab.dart     # 観測記録タブ（タイムライン）
    settings_tab.dart    # 設定タブ（アカウント、プレミアム、プライバシー）
```

## 実装状況

### v1.0 Phase 1（完了）：簡単な実装
- [x] プロジェクト作成
- [x] 基本的なナビゲーション (GoRouter + BottomNavigationBar)
- [x] 9画面のスケルトン実装
  - スプラッシュ画面
  - ログイン画面
  - ホーム画面（4タブ）
- [x] 図鑑の基本UI（グリッド表示）
- [x] 観測記録タイムライン（簡易版）
- [x] 設定画面（レイアウト）

### 次のステップ：難しい実装（SONNETで実装予定）
- [ ] **Firebase連携** — 認証、Firestore
- [ ] **AR観測機能** — GPS + センサー融合（ジャイロ、磁気、加速度計）
- [ ] **Bortleスケール判定** — 光害マップローカルキャッシュ
- [ ] **星座データモデル** — 88星座 + 50天体のマスターデータ
- [ ] **タイムカプセル天体管理** — イベントマスター、自動ページ解放
- [ ] **夜空Connect** — リアルタイムユーザー数表示
- [ ] **プレミアム課金** — RevenueCat統合
- [ ] **神話キャラクター図鑑** — イラスト + テキスト
- [ ] **複雑なAR描画** — 星座ライン、難易度インジケーター

## 開発フロー

### 簡単な実装（Phase 1 完了）
1. UI フレームワークの構築 ✅
2. 画面遷移フロー ✅
3. 基本的なウィジェット ✅

### 次：Phase 2（SONNETで実装）
1. データモデル定義
2. Firebase接続
3. AR基盤実装
4. 光害マップデータ統合

## デザイン決定事項

- **色**: インディゴ + パープル + ゴールド（星の色）
- **フォント**: Material 3デフォルト
- **ナビゲーション**: Material 3 NavigationBar（ボトムタブ）
- **状態管理**: Riverpod（準備済み）

## 実行方法

```bash
# 依存関係取得
flutter pub get

# Chromeで実行（開発環境）
flutter run -d chrome

# Android（未テスト：adb設定が必要）
flutter run -d android

# iOS（Mac必須）
flutter run -d ios
```

## トラブルシューティング

### adb: Process exited abnormally
→ Chrome/Web実行で対応。Android実装は後で。

### ホットリロードが効かない
→ `flutter run --no-build-separate-app`

## 次フェーズの目標（SONNETへの指示）

1. **認証基盤** — ゲスト/メール登録の実装
2. **星座マスターデータ** — 88星座の詳細情報（神話、赤経・赤緯など）
3. **AR実装** — センサーベース疑似AR（GPS + ジャイロ + 磁気）
4. **観測データ永続化** — Firestore スキーマ + CRUD操作
5. **Bortleスケール** — 光害マップローカルキャッシュ・判定ロジック
