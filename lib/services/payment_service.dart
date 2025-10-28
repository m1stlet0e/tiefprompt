import 'package:dio/dio.dart';
import 'package:promptify/models/payment_model.dart';

/// 支付服务
class PaymentService {
  static const String _baseUrl = 'https://your-api.example.com/api';
  
  late final Dio _dio;
  
  PaymentService() {
    _dio = Dio(BaseOptions(baseUrl: _baseUrl));
  }

  /// 创建支付订单
  Future<PaymentResult?> createOrder({
    required String userId,
    required double amount,
    required PaymentMethod method,
    required String productId,
  }) async {
    try {
      final response = await _dio.post(
        '/payment/create-order',
        data: {
          'userId': userId,
          'amount': amount,
          'method': method.name,
          'productId': productId,
        },
      );

      if (response.statusCode == 200) {
        return PaymentResult.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error creating payment order: $e');
      return null;
    }
  }

  /// 查询订单状态
  Future<PaymentOrder?> getOrderStatus(String orderId) async {
    try {
      final response = await _dio.get('/payment/order/$orderId');
      
      if (response.statusCode == 200) {
        return PaymentOrder.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error getting order status: $e');
      return null;
    }
  }

  /// 确认支付完成
  Future<bool> confirmPayment(String orderId) async {
    try {
      final response = await _dio.post(
        '/payment/confirm',
        data: {'orderId': orderId},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error confirming payment: $e');
      return false;
    }
  }
}
