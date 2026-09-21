import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/purchase_service.dart';

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  return const PurchaseService();
});

class CustomerInfoNotifier extends StateNotifier<CustomerInfo?> {
  final PurchaseService _service;
  void Function(CustomerInfo)? _listener;

  CustomerInfoNotifier(this._service) : super(null) {
    _init();
  }

  Future<void> _init() async {
    state = await _service.getCustomerInfo();
    _listener = (info) => state = info;
    _service.addCustomerInfoUpdateListener(_listener!);
  }

  /// 購入・復元操作の直後にRevenueCatから返ってきたCustomerInfoを反映する。
  void setCustomerInfo(CustomerInfo info) => state = info;

  Future<void> refresh() async {
    state = await _service.getCustomerInfo();
  }

  @override
  void dispose() {
    final listener = _listener;
    if (listener != null) {
      _service.removeCustomerInfoUpdateListener(listener);
    }
    super.dispose();
  }
}

final customerInfoProvider =
    StateNotifierProvider<CustomerInfoNotifier, CustomerInfo?>((ref) {
  return CustomerInfoNotifier(ref.watch(purchaseServiceProvider));
});

/// プレミアムentitlementが有効かどうか。CustomerInfo取得前はfalse。
final isPremiumProvider = Provider<bool>((ref) {
  final service = ref.watch(purchaseServiceProvider);
  final info = ref.watch(customerInfoProvider);
  return service.isPremiumActive(info);
});

/// 現在のオファリング（購入可能な商品パッケージ群）。
final currentOfferingProvider = FutureProvider<Offering?>((ref) {
  return ref.watch(purchaseServiceProvider).getCurrentOffering();
});
