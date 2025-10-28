import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promptify/models/payment_model.dart';
import 'package:promptify/services/payment_service.dart';

/// 支付服务提供者
final paymentServiceProvider = Provider((ref) {
  return PaymentService();
});

/// 创建支付订单
final createPaymentOrderProvider = 
  FutureProvider.family<PaymentResult?, PaymentOrderParams>((ref, params) async {
  final paymentService = ref.watch(paymentServiceProvider);
  
  return await paymentService.createOrder(
    userId: params.userId,
    amount: params.amount,
    method: params.method,
    productId: params.productId,
  );
});

/// 支付订单参数
class PaymentOrderParams {
  final String userId;
  final double amount;
  final PaymentMethod method;
  final String productId;

  PaymentOrderParams({
    required this.userId,
    required this.amount,
    required this.method,
    required this.productId,
  });
}
