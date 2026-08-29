# セキュリティ調査レポート（星座コレ！）

- 調査日: 2026-08-29
- 対象: `com.petitworksapps.seizakore`（Flutterアプリ, Firebase連携）
- 重点項目: ① API通信の暗号化 ② Firestore権限（最小権限） ③ セキュリティ改善提案（APIキー運用・ログ/監査）
- 手法: リポジトリのソースコード・設定ファイルの静的レビュー（OWASP MASVSベースのチェックリストに準拠）

> 本調査はコードベースの静的レビューです。Firebase/Google Cloud コンソール側の実設定（Firestoreルール本体、APIキー制限、App Check有効化状況など）は確認できていません。★印の項目はコンソール側での実値確認が必須です。

---

## 1. 総括（優先度順）

| # | 重要度 | 項目 | 状態 |
|---|---|---|---|
| 1 | 🔴 Critical | Firestoreセキュリティルールがリポジトリに存在しない | ★要確認 |
| 2 | 🔴 Critical | リリースAPKがdebug鍵で署名されている | 未対応 |
| 3 | 🟠 High | 4アプリが同一Firebaseプロジェクト・同一APIキーを共有 | 未対応 |
| 4 | 🟡 Medium | Firebase App Check 未導入 | 未対応 |
| 5 | 🟡 Medium | Firebase APIキーの利用制限（アプリ/パッケージ制限）未確認 | ★要確認 |
| 6 | 🟡 Medium | Dependabotが未設定（依存パッケージ脆弱性チェックなし） | 未対応 |
| 7 | 🟢 Low | GitHub ActionsのサードパーティActionsがタグ固定（SHA固定でない） | 未対応 |
| 8 | 🟢 Low | ワークフローの`permissions`が明示されていない | 未対応 |
| 9 | ✅ Good | API通信はFirebase SDK経由のみ。TLS/ATSの平文許可なし | 問題なし |
| 10 | ℹ️ Info | Firestore/Auth連携コードはUIに未接続（実装途中） | 参考情報 |

---

## 2. チェックリスト（OWASP MASVSベース）

### 通信（① API通信の暗号化）

- [x] TLS通信のみ使用（`http`パッケージ等の独自通信コードは存在せず、`firebase_auth`/`cloud_firestore`のSDK通信のみ。SDKは内部でTLS 1.2+を強制）
- [x] App Transport Security (ATS) の平文http例外なし — `ios/Runner/Info.plist`に`NSAppTransportSecurity`/`NSAllowsArbitraryLoads`の記述なし（デフォルトのATS適用＝HTTPS必須）
- [x] Android `usesCleartextTraffic`や`network_security_config.xml`による平文許可なし（未設定＝デフォルトでAPI28+はcleartext拒否）
- [ ] Certificate Pinningは未導入（Firebase SDK標準構成のため必須ではないが、機密性の高いデータを扱う場合は検討の余地あり）
- [x] 証明書検証を無効化するデバッグコードは見当たらない

**結論**: 独自API通信は存在せず、すべてFirebase公式SDK経由。TLSは既定で強制されており、平文通信を許可する設定もない。この観点では大きな問題なし。

### データベース権限（② Firestoreセキュリティルール）

- [ ] ★**`firestore.rules` / `firebase.json` がリポジトリに存在しない**。ルールがバージョン管理されておらず、コードからは最小権限が守られているか検証不能。Firebaseプロジェクトを新規作成した場合のデフォルト（テストモード = `allow read, write: if true`）のまま本番運用されていないか、**コンソールで至急確認が必要**。
- [x] クライアントコード側の設計自体は妥当：`lib/providers/firestore_provider.dart`は常に`users/{uid}/...`パスに対して読み書きしており、他ユーザーのuidを跨いだ参照は行っていない。ただし、これは**Firestoreルールが`request.auth.uid == uid`を強制していて初めて安全**になる設計であり、ルールがない/緩い場合は任意ユーザーが他人のデータを読み書きできる。
- [x] 管理者権限（isAdmin等）のクライアント側フラグは存在しない（良い設計。権限判定をクライアントに持たせていない）
- [ ] `firebase_auth`の`signInAnonymously`が有効（`lib/providers/firebase_auth_provider.dart:41`）。匿名ユーザーにも通常ユーザーと同じFirestore権限を与える設計だと、捨てアカウント大量生成によるデータ汚染・DoS的濫用のリスクがある。ルール側でレート制御や書き込みサイズ制限を検討すべき。
- [ ] Firestoreの複合クエリ（`where('constellationId', ...).orderBy('timestamp', ...)`）に対応するインデックス定義もリポジトリに見当たらない（`firestore.indexes.json`なし）。将来的にルールと合わせてIaC化を推奨。

**推奨対応（最優先）**:
1. `firebase.json` + `firestore.rules` をリポジトリに追加し、以下を明文化する：
   ```
   match /users/{uid} {
     allow read, write: if request.auth != null && request.auth.uid == uid;
     match /observations/{obsId} {
       allow read, write: if request.auth != null && request.auth.uid == uid;
     }
   }
   ```
2. Firebase Consoleで現在有効なルールを確認し、テストモードのままなら即座に上記に置き換える。
3. `firebase emulators:exec`等でルールのユニットテストをCIに組み込み、リグレッションを防止する。

### バックエンド連携・APIキー運用（③ セキュリティ改善提案）

- [ ] ★ `android/app/google-services.json`が**4つの異なるアプリ**（`nitesaki`, `seizakore`, `senjoshogi`, `shinjukuleague`）に対して**同一のFirebase APIキー**(`AIzaSyDqvv...upjFY`)・**同一プロジェクト**(`apps2-752cb`)を共有している。Firestoreルールがコレクション/アプリ単位で正しく分離されていないと、1アプリの脆弱なルールが他3アプリのユーザーデータ漏洩にも直結する「影響範囲の拡大（blast radius）」リスクがある。可能であれば長期的にアプリごとにFirebaseプロジェクトを分離するか、最低限ルールで`request.resource`のアプリ識別を厳格化することを推奨。
- [ ] ★ このAPIキーがGoogle Cloud Console側で「Androidアプリ制限（パッケージ名+SHA-1）」がかかっているか未確認。Firebase APIキーは秘匿情報ではないが、無制限だとキーを流用した不正リクエストが可能になるため、コンソールでのAPIキー制限設定を推奨。
- [ ] Firebase App Check（Play Integrity / DeviceCheck）が未導入。改ざんアプリ・エミュレータ・スクリプトからの不正リクエストを弾く仕組みがない。Firestore/Authに対してApp Checkを有効化することを推奨。
- [ ] APIキーの定期ローテーション運用が確認できない。Firebase APIキーはローテーションの概念が薄い（アプリ識別子に近い）ため、ローテーションよりも「制限設定＋App Check」を優先し、万一漏洩・濫用が疑われた場合のみコンソールでキー無効化/再発行する運用ルールを文書化することを推奨。
- [ ] Firestore/Authへのアクセスログ・監査ログの活用が未設定。Google Cloud の「Firestore監査ログ（Data Access audit logs）」を有効化し、異常な大量読み取り等を検知できるようにすることを推奨（個人開発規模でもコスト影響は軽微）。

### 配布物・CI/CD

- [ ] 🔴 **`android/app/build.gradle.kts`でリリースビルドがdebug鍵で署名されている**（`signingConfig = signingConfigs.getByName("debug")`、TODOコメントで「本番署名鍵を追加すること」と明記されたまま未対応）。`.github/workflows/deploy.yml`は`v*`タグpushで`flutter build apk --release`を実行しており、**現状ではdebug鍵で署名されたAPKがそのままリリース候補として生成される**。debug.keystoreは公開鍵・秘密鍵ともに広く知られたデフォルト値であり、そのAPKを配布すると第三者が同じ鍵で偽アップデートを作成できてしまう可能性がある（Google Play経由配布ならPlay側の署名管理でリスク軽減されるが、直接配布/サイドロードの場合は影響大）。**本番用keystoreを作成し、GitHub Actions Secretsに格納した上でCIから署名する構成に変更することを強く推奨**。
- [ ] Dependabot設定（`dependabot.yml`）がリポジトリに存在せず、`pub`パッケージやGitHub Actionsの依存脆弱性が自動検知されない。
- [ ] `.github/workflows/deploy.yml`のサードパーティAction（`actions/checkout@v3`, `subosito/flutter-action@v2`）がタグ指定であり、commit SHA固定になっていない（サプライチェーン攻撃対策としてはSHA固定が望ましい）。
- [ ] ワークフローに`permissions:`が明示されておらず、デフォルト権限（リポジトリ設定依存、広めになりがち）で動作している。`permissions: contents: read`等、必要最小限を明示することを推奨。
- [x] リリースビルドでのデバッグログ出力は最小限（`debugPrint`が1箇所のみ、内容はエラーオブジェクトの出力でPIIなし）
- [ ] 難読化（`--obfuscate`）やクラッシュレポート（Crashlytics）は未導入。現時点でユーザーの機密データを多く扱うアプリではないため優先度は低いが、将来的な検討事項として記録。

---

## 3. 良好だった点

- 独自の通信コードを持たず、通信はすべてFirebase公式SDK経由 → TLSやレスポンス検証を自前実装するリスクがない。
- iOS/AndroidともにATS/cleartext設定の平文許可を追加していない（デフォルトのHTTPS強制を維持）。
- クライアント側に管理者権限フラグや権限判定ロジックを持たせておらず、権限判断をFirestoreルール側に委譲する設計方針自体は適切。
- APIキーや資格情報のハードコードは（Firebase設定ファイル以外に）見当たらない。`webFirebaseConfig`のWeb用キーも現状は空文字で未設定のまま安全側に倒されている。

---

## 4. 次のアクション（優先度順）

1. **[Critical]** Firebase Consoleで現在のFirestoreルールを確認し、`firestore.rules`としてリポジトリに追加・バージョン管理する。テストモード（全許可）のままなら即修正。
2. **[Critical]** 本番用Android署名鍵を作成し、GitHub Actions Secrets経由でリリースビルドに使用するよう`build.gradle.kts`と`deploy.yml`を修正する。
3. **[High]** 共有Firebaseプロジェクト内の4アプリ分のFirestoreルール/コレクション設計を洗い出し、アプリ間のデータ越境がないことを確認する。
4. **[Medium]** Firebase App Checkを導入し、APIキーのアプリ/パッケージ制限をGoogle Cloud Consoleで設定する。
5. **[Medium]** `dependabot.yml`を追加し、依存パッケージの脆弱性を自動検知する。
6. **[Low]** GitHub ActionsのAction参照をcommit SHA固定にし、`permissions`を最小権限で明示する。
