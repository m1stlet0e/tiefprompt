import 'package:promptify/core/constants.dart';
import 'package:uuid/uuid.dart';

/// 支付宝登录响应
class AlipayLoginResponse {
  final String code;
  final String? userId;
  final String? nickname;
  final String? avatarUrl;

  AlipayLoginResponse({
    required this.code,
    this.userId,
    this.nickname,
    this.avatarUrl,
  });
}

/// 支付宝支付响应
class AlipayPaymentResponse {
  final bool success;
  final String? tradeNo;
  final String? errorMessage;

  AlipayPaymentResponse({
    required this.success,
    this.tradeNo,
    this.errorMessage,
  });
}

/// 支付宝服务 - 处理支付宝支付和授权登录
class AlipayService {
  static const String _appId = AppConfig.alipayAppId;

  /// 发起支付宝授权登录
  /// 在真实环境中，这会触发支付宝应用
  /// 在 Mock 模式下，直接返回 Mock 数据
  Future<AlipayLoginResponse?> login() async {
    try {
      _logDebug('🔄 发起支付宝登录...');

      if (MockConfig.useMockData) {
        // Mock 模式
        await _simulateNetworkDelay();
        final code = _generateMockCode();
        _logDebug('✅ 支付宝登录成功 (Mock)，授权码: $code');
        return AlipayLoginResponse(
          code: code,
          userId: 'alipay_user_${const Uuid().v4().substring(0, 8)}',
          nickname: '支付宝用户',
          avatarUrl: 'https://via.placeholder.com/150',
        );
      }

      // TODO: 真实环境中集成 flutter_alipay 包
      // 需要的步骤：
      // 1. pubspec.yaml 添加 flutter_alipay 包
      // 2. iOS 配置 URL Schemes
      // 3. Android 配置应用签名
      // 4. 调用支付宝授权登录 API
      
      _logDebug('⚠️ 支付宝 SDK 未集成，请将 APP_ID 设置为真实值并集成 flutter_alipay 包');
      return null;
    } catch (e) {
      _logDebug('❌ 支付宝登录失败: $e');
      rethrow;
    }
  }

  /// 发起支付宝支付
  /// 在真实环境中，这会触发支付宝应用
  /// 在 Mock 模式下，直接返回 Mock 数据
  Future<AlipayPaymentResponse?> pay({
    required String orderId,
    required double amount,
    required String description,
  }) async {
    try {
      _logDebug('🔄 发起支付宝支付...');
      _logDebug('   订单: $orderId');
      _logDebug('   金额: ¥$amount');
      _logDebug('   描述: $description');

      if (MockConfig.useMockData) {
        // Mock 模式 - 模拟支付成功
        await _simulateNetworkDelay();
        final tradeNo = _generateMockTradeNo();
        _logDebug('✅ 支付宝支付成功 (Mock)，交易单号: $tradeNo');
        return AlipayPaymentResponse(
          success: true,
          tradeNo: tradeNo,
        );
      }

      // TODO: 真实环境中集成 flutter_alipay 包
      // 需要的步骤：
      // 1. 从后端获取支付参数
      // 2. 调用 flutter_alipay.pay()
      // 3. 处理支付结果
      
      _logDebug('⚠️ 支付宝支付 SDK 未集成');
      return null;
    } catch (e) {
      _logDebug('❌ 支付宝支付失败: $e');
      return AlipayPaymentResponse(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  // ===== Mock 数据生成方法 =====

  /// 生成 Mock 授权码
  String _generateMockCode() {
    return 'mock_code_${const Uuid().v4().substring(0, 20)}';
  }

  /// 生成 Mock 交易单号
  String _generateMockTradeNo() {
    return 'mock_trade_${const Uuid().v4().substring(0, 20)}';
  }

  /// 模拟网络延迟
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(
      Duration(milliseconds: MockConfig.mockNetworkDelay),
    );
  }

  /// Debug 日志输出
  void _logDebug(String message) {
    if (MockConfig.enableDebugLogging) {
      print('[AlipayService] $message');
    }
  }
}
