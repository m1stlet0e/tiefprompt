import 'package:freezed_annotation/freezed_annotation.dart' show JsonKey;

/// 支付方式枚举
enum PaymentMethod {
  wechat,
  alipay,
  applePay,
  googlePay,
}

/// 支付订单
class PaymentOrder {
  final String orderId;
  final String userId;
  final double amount;
  final PaymentMethod method;
  final String productId;
  final String status;
  final DateTime? createdAt;
  final DateTime? completedAt;

  const PaymentOrder({
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.method,
    required this.productId,
    this.status = 'pending',
    this.createdAt,
    this.completedAt,
  });
  
  static PaymentOrder fromJson(Map<String, dynamic> json) {
    return PaymentOrder(
      orderId: json['orderId'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => PaymentMethod.wechat,
      ),
      productId: json['productId'] as String,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : null,
      completedAt: json['completedAt'] != null
        ? DateTime.parse(json['completedAt'] as String)
        : null,
    );
  }
}

/// 支付初始化结果
class PaymentResult {
  final String orderId;
  final String paymentString;
  final PaymentMethod method;
  final DateTime? expiresAt;

  const PaymentResult({
    required this.orderId,
    required this.paymentString,
    required this.method,
    this.expiresAt,
  });
  
  static PaymentResult fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      orderId: json['orderId'] as String,
      paymentString: json['paymentString'] as String,
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => PaymentMethod.wechat,
      ),
      expiresAt: json['expiresAt'] != null
        ? DateTime.parse(json['expiresAt'] as String)
        : null,
    );
  }
}
