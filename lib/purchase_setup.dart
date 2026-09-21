/// RevenueCatプロジェクトの設定。
///
/// RevenueCatダッシュボード（https://app.revenuecat.com）で以下を行い、
/// 発行された公開SDKキーをここに設定してください。
/// 1. プロジェクトを作成し、iOS/Androidアプリを追加
/// 2. Project settings > API keys から、プラットフォームごとの公開SDKキーを取得
/// 3. Entitlements で `premium` という名前のentitlementを作成
/// 4. Offerings で商品（ストア側の課金アイテムと紐付け）を作成し、
///    上記entitlementに紐付ける
///
/// APIキーが未設定（空文字）の場合、[initializePurchases]は何もせずに
/// 早期リターンする。プレミアム機能は常に未購入状態として扱われる。
const String revenueCatApiKeyAndroid = '';
const String revenueCatApiKeyIOS = '';

/// RevenueCatダッシュボードで作成するentitlement ID。
const String premiumEntitlementId = 'premium';
