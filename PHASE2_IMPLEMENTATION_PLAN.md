# Phase 2 実装計画書（SONNET対応）

**実装者**: Claude Sonnet  
**開始**: Phase 1 完了後  
**期間**: 6週間（Week 3-8）  
**目標**: v1.0リリース可能な状態

---

## Phase 2 全体構成

```
Week 3-4: コアデータ + AR基盤
  ├─ 星座データモデル（88星座 + 50天体）
  ├─ Firebase スキーマ設計 + CRUD
  ├─ AR観測基盤（GPS + センサー融合）
  └─ 夜間赤色モード

Week 5-6: 革新機能（シティ・ライト + タイムカプセル）
  ├─ Bortleスケール判定ロジック + 光害マップ
  ├─ シティ・ライト・チャレンジUI実装
  ├─ タイムカプセル天体管理 + イベント自動化
  └─ 神話キャラ図鑑（20体テキスト + イラスト）

Week 7: 夜空Connect + プライバシー
  ├─ 位置情報共有フロー
  ├─ リアルタイムユーザー数表示
  └─ プライバシー設定UI

Week 8: QA + リリース準備
  ├─ 端末テスト（複数GPS環境）
  ├─ Bortleスケール精度検証
  ├─ App Store / Google Play 申請書類
  └─ 初期マーケティング用スクリーンショット
```

---

## Phase 2A：Week 3-4（コア機能）

### 1️⃣ 星座データモデル

**ファイル**: `lib/models/constellation.dart`

```dart
class Constellation {
  final String id;              // 'orion', 'gemini' など
  final String nameJa;          // 'オリオン座'
  final String nameEn;          // 'Orion'
  final String category;        // 'zodiac' | 'northern' | 'southern'
  
  // 天文データ
  final String rightAscension;  // '05h 30m'
  final String declination;     // '+05°'
  final List<String> brightStars; // ['リゲル', 'ベテルギウス']
  final String peakMonths;      // '12月〜3月'
  
  // UI
  final String mythologyText;   // 300-500字のギリシャ神話
  final String imagePath;       // assets/constellations/orion.png
  final int difficulty;         // 1-5（見つけやすさ）
}

class CelestialBody {
  final String id;
  final String nameJa;
  final String type;            // 'planet' | 'star' | 'nebula' | 'cluster'
  final double magnitude;       // 明るさ
  // ... etc
}
```

**データソース**: 設計Step 2（Firestoreスキーマ）参照

**実装内容**:
- [ ] 88星座マスターデータ JSON → Firestore
- [ ] 50天体マスターデータ JSON → Firestore
- [ ] 神話テキスト（各星座300-500字）
- [ ] アセット管理（イラスト、アイコン）

---

### 2️⃣ Firebase スキーマ + 認証

**ファイル**: `lib/services/firebase_service.dart`

```dart
// Firestore Collections
users/
  {uid}
    ├─ displayName: string
    ├─ email: string
    ├─ isGuest: bool
    ├─ isPremium: bool
    ├─ premiumExpires: timestamp
    └─ createdAt: timestamp

constellations/
  {constellationId}
    ├─ nameJa: string
    ├─ mythology: string
    ├─ brightStars: array
    └─ ... (上記Constellationモデル)

observations/
  {observationId}
    ├─ userId: string
    ├─ constellationId: string
    ├─ timestamp: timestamp
    ├─ location: geopoint
    ├─ bortleScale: int (1-9)
    ├─ weather: string
    ├─ notes: string
    ├─ photoUrls: array
    └─ difficulty: int (記録時点のBortleベース)

timecapsule_events/
  {eventId}
    ├─ name: string
    ├─ eventType: string ('meteor' | 'eclipse' | 'conjunction')
    ├─ openTime: timestamp
    ├─ closeTime: timestamp
    ├─ description: string
    └─ year: int

user_timecapsule_records/
  {recordId}
    ├─ userId: string
    ├─ eventId: string
    ├─ observedAt: timestamp
    ├─ meteorCount: int (流星数)
    ├─ notes: string
    └─ photoUrls: array
```

**実装内容**:
- [ ] Firebase認証（メール + Google）
- [ ] Firestore セキュリティルール設定
- [ ] CRUD Operations（observationsテーブル）
- [ ] リアルタイム購読（Riverpod Provider）
- [ ] オフラインキャッシュ設定

---

### 3️⃣ AR観測基盤実装

**ファイル**: `lib/services/ar_service.dart` + `lib/screens/ar_observation_screen.dart`

**技術仕様**:
```dart
class ARService {
  // センサーフュージョン
  late StreamSubscription<AccelerometerEvent> accelerometer;
  late StreamSubscription<GyroscopeEvent> gyroscope;
  late StreamSubscription<MagnetometerEvent> magnetometer;
  late StreamSubscription<UserAccelerometerEvent> userAccelerometer;
  
  // GPS
  final geolocator = Geolocator();
  
  // 計算結果
  final deviceOrientation = StreamController<DeviceOrientation>();
  
  void _calculateOrientation() {
    // 加速度計（重力方向）+ ジャイロ（回転速度）+ 磁気（方位）
    // → 3D姿勢角（ロール、ピッチ、ヨー）を計算
  }
  
  void _matchConstellation(Position gps, DeviceOrientation orientation) {
    // GPS + 姿勢角から「スマホがどの星座を向いているか」判定
    // 3秒以上フォーカスで確定
  }
}
```

**UI実装**:
- [x] カメラプレビュー（camera / camera_android / camera_ios）
- [ ] 星座ライン描画（星図計算エンジン）
- [ ] 難易度インジケーター（Bortleスケール表示）
- [ ] 認識中アニメーション（3秒カウント）
- [ ] 夜間赤色モード（Canvas描画色フィルター）
- [ ] 撮影ボタン → 観測記録保存

**依存関係追加**:
```yaml
camera: ^0.10.0
geolocator: ^9.0.0
sensors_plus: ^1.4.0
```

---

### 4️⃣ 夜間赤色モード

**ファイル**: `lib/widgets/red_night_mode.dart`

```dart
class RedNightModeFilter extends StatelessWidget {
  // Canvas上に赤いフィルターを半透明でオーバーレイ
  // 目の順応を保護しながら暗さを確保
  
  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(
        Color.fromARGB(100, 255, 50, 50),
        BlendMode.darken,
      ),
      child: child,
    );
  }
}
```

---

## Phase 2B：Week 5-6（革新機能）

### 5️⃣ Bortleスケール判定 + 光害マップ

**ファイル**: `lib/services/light_pollution_service.dart`

```dart
class LightPollutionService {
  // 日本全域のBortleスケール固定マップ（3段階版）
  // → アセットとしてローカル保存（Firebase Storageから初回DLでキャッシュ）
  
  late Map<String, int> bortleMap; // 緯度経度グリッド → Bortleスケール
  
  Future<int> getBortleScale(double latitude, double longitude) async {
    // GPS座標 → 最も近い100m×100m グリッドを検索
    // → Bortleスケール（1-9）を返す
    
    // v1.0: 3段階簡易版
    //   1-3: 暗い（郊外・山間部）
    //   4-6: 中程度（郊外）
    //   7-9: 明るい（都市部）
  }
  
  String getBortleDescription(int scale) {
    // 1 = "最暗黒" → 9 = "大都市"
  }
}
```

**データ準備**:
- [ ] Bortleスケール固定マップの取得・JSON化
  - 国立天文台公開データ または OpenStreetMap + NOAA VIIRS
  - 日本全域を100m×100m グリッドで分割
  - Firebase Storage に保存
- [ ] 初回起動時にダウンロード + ローカルキャッシュ
- [ ] キャッシュ有効期限（3ヶ月）管理

---

### 6️⃣ シティ・ライト・チャレンジ UI 統合

**ファイル**: `lib/widgets/constellation_detail_screen.dart`

**表示内容**:
```
┌─────────────────────────────┐
│ ← オリオン座       ★ ⋯      │
├─────────────────────────────┤
│ 難易度: ★★★ (東京)         │ ← Bortleスケール自動判定
│ 観測回数: 5回               │
│ 最高難易度: ★★★           │
├─────────────────────────────┤
│ [最近の観測]                │
│ 2026-06-20 東京 ★★★       │
│ 2026-06-15 長野 ★☆☆       │
│ 2026-06-10 沖縄 ★☆☆       │
└─────────────────────────────┘
```

**実装内容**:
- [ ] GPS + Bortleマップから自動難易度計算
- [ ] 観測地ごとに難易度を履歴保存
- [ ] 「東京でのオリオン座★★★」と「長野でのオリオン座★」を区別表示
- [ ] 難易度レアランキング（都市部ユーザーむけ演出）

---

### 7️⃣ タイムカプセル天体管理

**ファイル**: `lib/services/timecapsule_service.dart`

```dart
class TimecapsuleService {
  // イベント自動管理
  
  Future<List<TimecapsuleEvent>> getActiveEvents() async {
    // 現在時刻でオープンになっているイベントのみ返す
  }
  
  Future<List<TimecapsuleEvent>> getUpcomingEvents(int daysAhead) async {
    // あと○日で開放されるイベント（プレビュー用）
  }
  
  Future<void> recordObservation(String eventId, {
    required int meteorCount,
    required String notes,
    required List<String> photoUrls,
  }) async {
    // イベント期間中のみ記録可能
    // 期間終了後は「記録は見放題だが新規記録不可」
  }
}

// イベントマスターデータ（年間12個+不定期）
class TimecapsuleEvent {
  final String id;
  final String name;          // 'ふたご座流星群'
  final DateTime openTime;    // 2026-12-13 00:00
  final DateTime closeTime;   // 2026-12-15 23:59
  final String description;
  final String type;          // 'meteor' | 'eclipse' | 'conjunction'
  final int year;
}
```

**実装内容**:
- [ ] イベントマスターデータ（年間12ヶ月 + 複数年分）をFirestoreに投入
- [ ] 自動ページ解放ロジック（Cloud Functionsで時刻ベース）
- [ ] タイムカプセル専用画面UI（カウントダウン表示）
- [ ] 観測記録永久保存（課金後）
- [ ] 「あと○日で開放」演出

**年間イベント例**:
```
- ふたご座流星群（12月13-14日）
- しぶんぎ座流星群（1月3-4日）
- 4月こと座流星群（4月22-23日）
- ペルセウス座流星群（8月12-13日）
- 皆既月食（不定期）
- 惑星大接近（不定期）
```

---

### 8️⃣ 神話キャラ図鑑

**ファイル**: `lib/widgets/mythology_view.dart`

**UI表示**:
```
┌─────────────────────────────┐
│ 【オリオン（狩人の星座）】  │
├─────────────────────────────┤
│  [キャラクターイラスト]     │
│                             │
│ ギリシャ神話では...         │
│ テキスト（300-500字）       │
│ 複数段落で読みやすく        │
└─────────────────────────────┘
```

**実装内容**:
- [ ] 神話テキスト（各星座300-500字）DB化
- [ ] キャラクターイラスト統合（assets/constellations/）
- [ ] テキスト + 画像レイアウト
- [ ] 複数言語対応準備（v1.0は日本語のみ）

---

## Phase 2C：Week 7（夜空Connect）

### 9️⃣ 位置情報共有 + プライバシー

**ファイル**: `lib/services/night_sky_connect_service.dart`

```dart
class NightSkyConnectService {
  Future<int> getUserCountForConstellation(
    String constellationId,
    String prefecture,  // 都道府県のみ送信（個人特定不可）
  ) async {
    // Firestore集計: observations{constellationId, prefecture}
    // リアルタイム性: 10分以内
    // → "今この星座を見ている人: ○人" 表示
  }
  
  // プライバシー設定
  Future<void> setLocationSharingEnabled(bool enabled) async {
    // デフォルト: OFF（未成年配慮）
    // Firestore: users{locationSharingEnabled}
  }
}
```

**実装内容**:
- [ ] AR観測画面下部に「今この星座を見ている人: ○人」表示
- [ ] 都道府県レベルのみ送信（緯度経度は送らない）
- [ ] ユーザー名は「星のひと」など匿名表示
- [ ] 流星群ピーク時「全国で○人」グローバル表示
- [ ] プライバシー設定UI（設定タブ）
- [ ] セキュリティルール：未成年はデフォルトOFF

---

## Phase 2D：Week 8（QA + リリース準備）

### 🔟 端末テスト + Bortleスケール精度検証

**テスト項目**:
- [ ] iOS 16+ / Android 8+ での動作確認
- [ ] GPS精度（複数地点での検証）
- [ ] センサー融合精度（ARの向き認識）
- [ ] Bortleスケール精度（実地調査3地点）
  - 東京都心（Bortle 8-9）
  - 郊外（Bortle 5-6）
  - 山間部（Bortle 1-3）
- [ ] オフラインモード動作確認
- [ ] バッテリー消費量測定

---

### ⑪ リリース準備

**実装内容**:
- [ ] App Store Screenshots（5言語対応）
- [ ] Google Play 説明文（350字以下）
- [ ] プライバシーポリシー最終版
- [ ] 利用規約
- [ ] アプリ内のヘルプテキスト翻訳
- [ ] アイコン + スプラッシュ画像最終版
- [ ] ビルド最適化（APK / IPA / AAB）

---

## 依存関係一覧（新規追加）

```yaml
# Camera + AR
camera: ^0.10.0
geolocator: ^9.0.0
sensors_plus: ^1.4.0

# Firebase
firebase_core: ^2.24.0
firebase_auth: ^4.10.0
firebase_firestore: ^4.13.0
firebase_storage: ^11.5.0

# Cache + Network
http: ^1.1.0
flutter_cache_manager: ^3.3.1

# State Management (Already: Riverpod)

# Image + Assets
cached_network_image: ^3.3.0
flutter_svg: ^2.0.0

# Monetization
revenue_cat_flutter: ^7.0.0

# Localization (準備)
intl: ^0.19.0 (Already)

# Analytics (Optional)
firebase_analytics: ^10.7.0
```

---

## 成功基準（Definition of Done）

✅ Week 3-4 チェック:
- [ ] 星座データマスター完成（88星座 + 50天体）
- [ ] Firebase スキーマ実装 + セキュリティルール
- [ ] 認証フロー（ゲスト/メール/Google）
- [ ] AR観測画面フル動作（カメラ + センサー）

✅ Week 5-6 チェック:
- [ ] Bortleスケール精度 ≥80%（3地点テスト）
- [ ] シティ・ライト・チャレンジ表示
- [ ] タイムカプセル自動管理
- [ ] 神話テキスト + イラスト統合

✅ Week 7 チェック:
- [ ] 夜空Connect表示
- [ ] プライバシー設定UI

✅ Week 8 チェック:
- [ ] iOS / Android 端末テスト合格
- [ ] App Store / Google Play 申請可能状態

---

## トラブルシューティング事前準備

### AR精度低い場合
→ センサーキャリブレーション画面追加（指8字描画）

### Bortleスケール精度低い場合
→ v1.0は3段階簡易版で妥協。v1.1で詳細化（25m×25m グリッド）

### Firebase 料金懸念
→ リアルタイムリッスン制限（観測記録のみ）。集計はバッチ処理

### 流星群期間のサーバー負荷
→ Cloud Functions のスケーリング事前設定

---

## 注意事項

⚠️ **子ども安全性**
- 位置情報送信時：都道府県レベル以下は非表示
- ユーザー名匿名化
- SNS/公開フィード機能は実装しない（v2.0以降）

⚠️ **法的対応**
- プライバシーポリシー（位置情報、データ保持期限）
- 利用規約（年齢制限：小学3年生以上推奨）
- GDPR/CCPA対応（データ削除権）

⚠️ **パフォーマンス**
- AR画面は 60fps 維持（スマホ発熱対策）
- オフラインキャッシュ（初回150MB程度）
- バッテリー消費警告表示

---

## 次フェーズ以降（v1.1+）

- 市民科学モード（ユーザー観測データ集計）
- 星座育成（観測でキャラが進化）
- 親子クエスト（親が子に課題出題）
- 多言語対応（英語、中国語）
- 衛星追跡（ISS等）
- おやすみプラネタリウム（寝かしつけ機能）
