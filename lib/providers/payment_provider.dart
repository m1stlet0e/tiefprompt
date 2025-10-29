import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promptify/services/payment_service.dart';

/// 支付服务提供者
final paymentServiceProvider = Provider((ref) {
  return PaymentService();
});

/// 创建支付订单
final createPaymentOrderProvider = 
  FutureProvider.family<PaymentOrder?, PaymentOrderParams>((ref, params) async {
  final paymentService = ref.watch(paymentServiceProvider);
  
  return await paymentService.createOrder(
    userId: params.userId,
    amount: params.amount,
    productId: params.productId,
    productName: params.productName,
    method: PaymentMethod.values.byName(params.method),
  );
});

/// 支付订单参数
class PaymentOrderParams {
  final String userId;
  final double amount;
  final String method;
  final String productId;
  final String productName;

  PaymentOrderParams({
    required this.userId,
    required this.amount,
    required this.method,
    required this.productId,
    required this.productName,
  });
}
