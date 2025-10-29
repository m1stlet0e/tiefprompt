import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:promptify/core/constants.dart';
import 'package:uuid/uuid.dart';

/// 支付订单模型
class PaymentOrder {
  final String orderId;
  final String userId;
  final double amount;
  final String productId;
  final String productName;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  PaymentOrder({
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.productId,
    required this.productName,
    required this.method,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory PaymentOrder.fromJson(Map<String, dynamic> json) {
    return PaymentOrder(
      orderId: json['orderId'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      method: PaymentMethod.values.byName(json['method'] as String),
      status: PaymentStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'amount': amount,
      'productId': productId,
      'productName': productName,
      'method': method.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

/// 支付方式
enum PaymentMethod {
  wechat,  // 微信支付
  alipay,  // 支付宝支付
}

/// 支付状态
enum PaymentStatus {
  pending,      // 待支付
  processing,   // 处理中
  completed,    // 已完成
  failed,       // 失败
  cancelled,    // 已取消
}

/// 支付服务
class PaymentService {
  late final Dio _dio;
  late final FlutterSecureStorage _secureStorage;

  PaymentService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: Duration(seconds: AppConfig.httpTimeoutSeconds),
        receiveTimeout: Duration(seconds: AppConfig.httpTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    _secureStorage = const FlutterSecureStorage();

    // 添加 Token 拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  /// 创建支付订单
  Future<PaymentOrder?> createOrder({
    required String userId,
    required double amount,
    required String productId,
    required String productName,
    required PaymentMethod method,
  }) async {
    try {
      if (MockConfig.useMockData) {
        // Mock 数据模式
        await _simulateNetworkDelay();
        return _generateMockOrder(
          userId: userId,
          amount: amount,
          productId: productId,
          productName: productName,
          method: method,
        );
      }

      final response = await _dio.post(
        ApiEndpoints.createOrder,
        data: {
          'userId': userId,
          'amount': amount,
          'productId': productId,
          'productName': productName,
          'method': method.name,
        },
      );

      if (response.statusCode == 200) {
        final order = PaymentOrder.fromJson(response.data);
        _logDebug('✅ 订单创建成功: ${order.orderId}');
        return order;
      }
      return null;
    } catch (e) {
      _logDebug('❌ 创建订单失败: $e');
      rethrow;
    }
  }

  /// 查询订单状态
  Future<PaymentOrder?> queryOrder(String orderId) async {
    try {
      if (MockConfig.useMockData) {
        // Mock 数据模式
        await _simulateNetworkDelay();
        return _generateMockOrder(orderId: orderId);
      }

      final response = await _dio.get(
        '${ApiEndpoints.queryOrder}/$orderId',
      );

      if (response.statusCode == 200) {
        final order = PaymentOrder.fromJson(response.data);
        _logDebug('✅ 查询订单成功: ${order.orderId}，状态: ${order.status.name}');
        return order;
      }
      return null;
    } catch (e) {
      _logDebug('❌ 查询订单失败: $e');
      rethrow;
    }
  }

  /// 确认支付（Mock 模式下立即成功）
  Future<bool> confirmPayment(String orderId) async {
    try {
      if (MockConfig.useMockData) {
        // Mock 数据模式
        await _simulateNetworkDelay();
        _logDebug('✅ 支付确认成功 (Mock): $orderId');
        return true;
      }

      final response = await _dio.post(
        ApiEndpoints.confirmPayment,
        data: {'orderId': orderId},
      );

      if (response.statusCode == 200) {
        _logDebug('✅ 支付确认成功: $orderId');
        return true;
      }
      return false;
    } catch (e) {
      _logDebug('❌ 支付确认失败: $e');
      rethrow;
    }
  }

  /// 处理微信支付结果
  Future<bool> handleWechatPaymentResult({
    required String orderId,
    required bool success,
  }) async {
    if (success) {
      return await confirmPayment(orderId);
    } else {
      _logDebug('⚠️ 微信支付取消');
      return false;
    }
  }

  /// 处理支付宝支付结果
  Future<bool> handleAlipayPaymentResult({
    required String orderId,
    required bool success,
  }) async {
    if (success) {
      return await confirmPayment(orderId);
    } else {
      _logDebug('⚠️ 支付宝支付取消');
      return false;
    }
  }

  // ===== Mock 数据生成方法 =====

  /// 生成 Mock 订单
  PaymentOrder _generateMockOrder({
    String? orderId,
    String? userId,
    double amount = 48.0,
    String productId = 'pro',
    String productName = 'Promptify Pro',
    PaymentMethod method = PaymentMethod.wechat,
  }) {
    return PaymentOrder(
      orderId: orderId ?? 'ORDER_${const Uuid().v4().substring(0, 12)}',
      userId: userId ?? 'user_mock',
      amount: amount,
      productId: productId,
      productName: productName,
      method: method,
      status: PaymentStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      completedAt: DateTime.now(),
    );
  }

  /// 模拟网络延迟
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(
      Duration(milliseconds: MockConfig.mockNetworkDelay),
    );
  }

  /// 获取 Access Token
  Future<String?> _getAccessToken() async {
    return await _secureStorage.read(key: 'accessToken');
  }

  /// Debug 日志输出
  void _logDebug(String message) {
    if (MockConfig.enableDebugLogging) {
      print('[PaymentService] $message');
    }
  }
}
