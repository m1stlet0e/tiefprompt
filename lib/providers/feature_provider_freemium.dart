import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:promptify/core/constants.dart';
import 'package:promptify/providers/app_features.dart';
import 'package:promptify/providers/banner_provider.dart';
import 'package:promptify/providers/feature_provider.dart';

/// Freemium版功能特性管理器
///
/// 付费增值模式的应用版本，用于 App Store 和 Google Play
/// - 免费版：提供基础功能
/// - 专业版：通过应用内购买解锁所有功能
class FeaturesFreemium extends Features {
  /// 应用内购买实例
  late final InAppPurchase _iap;
  
  /// 购买事件监听订阅
  late final StreamSubscription<List<PurchaseDetails>> _sub;

  /// 商品ID集合（专业版ID）
  final Set<String> _productIds = {kProId};
  
  /// 可购买的商品详情
  final Map<String, ProductDetails> _products = {};
  
  /// 用户已拥有的商品ID
  final Set<String> _owned = {};
  
  /// IAP 是否可用
  bool _iapAvailable = false;

  /// 引导初始化应用内购买系统
  ///
  /// 执行步骤：
  /// 1. 检查应用内购买是否可用
  /// 2. 监听购买事件流
  /// 3. 查询商品详情
  /// 4. 恢复之前的购买记录
  ///
  /// 返回：是否初始化成功
  @override
  Future<bool> bootstrap() async {
    _iap = InAppPurchase.instance;

    // 检查应用内购买是否可用
    try {
      _iapAvailable = await _iap.isAvailable();
      if (!_iapAvailable) {
        // 模拟器或 IAP 不可用时的处理
        // 在模拟器上显示信息但继续运行
        if (Platform.isIOS || Platform.isAndroid) {
          // 真实设备或真实商店
          ref.read(bannerMessageProvider.notifier).state =
              "Failed to initialize payment model: InAppPurchase is not available";
          return false;
        }
        // 模拟器：允许继续运行但不能购买
        return true;
      }
    } catch (e) {
      // 捕捉异常但不中断应用运行
      print("IAP initialization error: $e");
      _iapAvailable = false;
      // 在模拟器上继续运行
      return true;
    }

    try {
      // 监听购买事件流
      _sub = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _sub.cancel(),
        onError: (error) {
          print("Purchase stream error: $error");
        },
      );

      // 查询商品详情
      final resp = await _iap.queryProductDetails(_productIds);
      if (resp.error != null) {
        print("Failed to query products: ${resp.error}");
      } else if (resp.notFoundIDs.isNotEmpty) {
        print("Product IDs not found: ${resp.notFoundIDs.join(", ")}");
      } else {
        _products.addEntries(resp.productDetails.map((p) => MapEntry(p.id, p)));
      }

      // 恢复之前的购买
      if (Platform.isAndroid) {
        try {
          final resp = await InAppPurchase.instance
              .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>()
              .queryPastPurchases();
          _onPurchaseUpdate(resp.pastPurchases);
        } catch (e) {
          print("Failed to query past purchases: $e");
        }
      } else {
        try {
          await _iap.restorePurchases();
        } catch (e) {
          print("Failed to restore purchases: $e");
        }
      }
    } catch (e) {
      print("Bootstrap error: $e");
    }
    return true;
  }

  /// 处理购买更新事件
  ///
  /// 当用户完成购买、恢复购买或购买失败时触发
  ///
  /// [details] - 购买详情列表
  void _onPurchaseUpdate(List<PurchaseDetails> details) {
    for (final p in details) {
      switch (p.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // 购买成功或恢复成功
          _owned.add(p.productID);
          state = build();  // 重建状态，解锁功能
          if (p.pendingCompletePurchase) _iap.completePurchase(p);
          break;
        case PurchaseStatus.error:
          // 购买失败
          print("Purchase error: ${p.error}");
          break;
        case PurchaseStatus.canceled:
        case PurchaseStatus.pending:
          // 用户取消或等待支付
          break;
      }
    }
  }

  /// 构建功能特性状态
  ///
  /// 根据用户是否购买专业版，返回对应的功能列表
  @override
  AppFeatures build() {
    if (_owned.contains(kProId)) {
      // 已购买专业版：解锁所有功能
      return AppFeatures(kAllFeatures, FeatureKind.paidVersion);
    }

    // 免费版：只提供基础功能
    return AppFeatures(kFreeFeatures, FeatureKind.freeVersion);
  }

  /// 购买专业版
  ///
  /// 触发应用内购买流程，购买专业版以解锁所有功能
  @override
  Future<void> buyPro() async {
    // 检查 IAP 是否可用
    if (!_iapAvailable) {
      ref.read(bannerMessageProvider.notifier).state =
          "In-App Purchase is not available on this device. Please use a real device with App Store or Google Play to make purchases.";
      return;
    }

    final proProduct = _products[kProId];

    // 检查是否已经拥有
    if (_owned.contains(kProId)) {
      ref.read(bannerMessageProvider.notifier).state =
          "You already own the Pro version.";
      return;
    }

    // 发起购买请求
    if (proProduct != null) {
      try {
        if (!await _iap.buyNonConsumable(
          purchaseParam: PurchaseParam(productDetails: proProduct),
        )) {
          ref.read(bannerMessageProvider.notifier).state =
              "Failed to complete purchase.";
        }
      } catch (e) {
        ref.read(bannerMessageProvider.notifier).state =
            "Failed to complete purchase: $e";
      }
    } else {
      ref.read(bannerMessageProvider.notifier).state =
          "The Pro version is not available on this device. Please use a real device with App Store or Google Play.";
    }

    return Future.value();
  }
}
