import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../purchase_setup.dart';

/// 購入がユーザーによってキャンセルされたことを示す例外。
/// エラーとして扱わず、静かに無視してよい。
class PurchaseCancelledException implements Exception {}

/// RevenueCat SDKのラッパー。
class PurchaseService {
  const PurchaseService();

  String get _apiKey => Platform.isIOS ? revenueCatApiKeyIOS : revenueCatApiKeyAndroid;

  bool get isConfigured => _apiKey.isNotEmpty;

  /// SDKを初期化する。APIキーが未設定の場合は何もしない。
  Future<void> initialize() async {
    if (!isConfigured) {
      debugPrint('RevenueCat: APIキー未設定のため初期化をスキップします');
      return;
    }
    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.warn);
    await Purchases.configure(PurchasesConfiguration(_apiKey));
  }

  /// 現在のentitlement状態を含むCustomerInfoを取得する。
  Future<CustomerInfo?> getCustomerInfo() async {
    if (!isConfigured) return null;
    return Purchases.getCustomerInfo();
  }

  /// 購入可能なオファリング（商品パッケージ群）を取得する。
  Future<Offering?> getCurrentOffering() async {
    if (!isConfigured) return null;
    final offerings = await Purchases.getOfferings();
    return offerings.current;
  }

  /// 指定パッケージを購入する。ユーザーがキャンセルした場合は
  /// [PurchaseCancelledException]をthrowする。
  Future<CustomerInfo> purchase(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      return result.customerInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        throw PurchaseCancelledException();
      }
      rethrow;
    }
  }

  Future<CustomerInfo> restorePurchases() {
    return Purchases.restorePurchases();
  }

  /// entitlementの購読を開始する。呼び出し側で保持し、不要になったら
  /// [Purchases.removeCustomerInfoUpdateListener]で解除すること。
  void addCustomerInfoUpdateListener(CustomerInfoUpdateListener listener) {
    if (!isConfigured) return;
    Purchases.addCustomerInfoUpdateListener(listener);
  }

  void removeCustomerInfoUpdateListener(CustomerInfoUpdateListener listener) {
    if (!isConfigured) return;
    Purchases.removeCustomerInfoUpdateListener(listener);
  }

  bool isPremiumActive(CustomerInfo? info) {
    if (info == null) return false;
    return info.entitlements.active.containsKey(premiumEntitlementId);
  }
}
