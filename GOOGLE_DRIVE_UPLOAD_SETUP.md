# Google Drive Automatic Upload Setup Guide

このガイドでは、GitHub Actions から Google Drive へ自動的に APK/AAB をアップロードするための設定手順を説明します。

## 必要な設定

Google Drive への自動アップロード機能を使用するには、以下の 2 つの GitHub secrets を設定する必要があります。

### 1. GOOGLE_DRIVE_SERVICE_ACCOUNT

Google Cloud Project のサービスアカウント JSON キーファイルの内容

**取得方法:**
1. [Google Cloud Console](https://console.cloud.google.com/) を開く
2. プロジェクトを選択または作成
3. 左メニュー → "サービス アカウント"
4. 新しいサービスアカウントを作成（または既存を選択）
5. 該当するサービスアカウントをクリック
6. "キー" タブ → "新しいキーを作成" → JSON
7. ダウンロードされた JSON ファイルの内容全体をコピー

**必要な権限:**
- Google Drive API へのアクセス権
- 対象の Google Drive フォルダへの書き込み権限

### 2. GOOGLE_DRIVE_FOLDER_ID

アップロード先の Google Drive フォルダ ID

**取得方法:**
1. [Google Drive](https://drive.google.com) を開く
2. アップロード先として使用するフォルダを作成または選択
3. ブラウザのアドレスバーから ID を取得:
   - URL: `https://drive.google.com/drive/folders/1a2b3c4d5e6f7g8h9i0j/`
   - フォルダ ID: `1a2b3c4d5e6f7g8h9i0j`
4. サービスアカウントが編集できるように、このフォルダを共有設定する

## GitHub に Secrets を設定する

1. このリポジトリの Settings ページを開く
2. 左メニュー → "Secrets and variables" → "Actions"
3. "New repository secret" をクリック

**GOOGLE_DRIVE_SERVICE_ACCOUNT を設定:**
- Name: `GOOGLE_DRIVE_SERVICE_ACCOUNT`
- Secret: Google Cloud から取得した JSON ファイルの内容全体をペースト

**GOOGLE_DRIVE_FOLDER_ID を設定:**
- Name: `GOOGLE_DRIVE_FOLDER_ID`
- Secret: Google Drive フォルダ ID をペースト

## 検証方法

### ステップ 1: CI/CD パイプラインの実行

secrets が正しく設定されたら、main ブランチに PR をマージして CI を実行します。

```bash
# または GitHub UI から "Run workflow" を選択
```

### ステップ 2: ビルド成功の確認

GitHub Actions で以下を確認:
- ✅ build ジョブ: success
- ✅ upload-to-google-drive ジョブ: success

### ステップ 3: Google Drive での確認

1. [Google Drive](https://drive.google.com) にアクセス
2. 設定したフォルダを開く
3. 以下のファイルが存在することを確認:
   - `app-release.apk`
   - `app-release.aab`
4. ファイルのタイムスタンプが最新であることを確認

## トラブルシューティング

### エラー: GOOGLE_DRIVE_SERVICE_ACCOUNT secret is not set

**原因:** GitHub secrets が設定されていない

**解決:**
1. Repository Settings → Secrets and variables → Actions
2. 上記の「GitHub に Secrets を設定する」セクションを参照

### エラー: Invalid JSON in GOOGLE_DRIVE_SERVICE_ACCOUNT

**原因:** JSON ファイルの内容が不正

**解決:**
1. Google Cloud から JSON キーを再ダウンロード
2. 余分な改行やスペースを除去して設定

### エラー: AAB upload failed

**原因:** サービスアカウントが Google Drive フォルダへの書き込み権限がない

**解決:**
1. Google Drive の対象フォルダを開く
2. フォルダの共有設定を開く
3. サービスアカウントのメール（JSON の `client_email` フィールド）を追加
4. 権限を「編集者」に設定

### ファイルが Google Drive に表示されない

**原因:** アップロード成功メッセージが表示されても、実際にはアップロードが失敗している場合がある

**確認方法:**
1. CI/CD ログで `rclone -v copy` コマンドの詳細出力を確認
2. エラーメッセージがないか確認
3. Google Drive API が有効になっているか確認

## セキュリティに関する注意

- **JSON キーを公開しないこと:** GitHub secrets は暗号化されますが、絶対にコミットしてはいけません
- **サービスアカウントの権限:** 最小権限の原則に従い、必要な権限のみを付与してください
- **定期的なキーローテーション:** Google Cloud のセキュリティベストプラクティスに従ってください

## 参考資料

- [Google Cloud サービスアカウント](https://cloud.google.com/docs/authentication/service-accounts)
- [GitHub Actions secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [rclone Google Drive backend](https://rclone.org/drive/)
