import 'package:promptify/core/constants.dart';
import 'package:uuid/uuid.dart';

/// 微信登录响应
class WechatLoginResponse {
  final String code;
  final String? sessionKey;
  final String? userId;
  final String? nickname;
  final String? avatarUrl;

  WechatLoginResponse({
    required this.code,
    this.sessionKey,
    this.userId,
    this.nickname,
    this.avatarUrl,
  });
}

/// 微信支付响应
class WechatPaymentResponse {
  final bool success;
  final String? transactionId;
  final String? errorMessage;

  WechatPaymentResponse({
    required this.success,
    this.transactionId,
    this.errorMessage,
  });
}

/// 微信服务 - 处理微信登录和支付
class WechatService {
  static const String _appId = AppConfig.wechatAppId;

  /// 发起微信登录
  /// 在真实环境中，这会触发微信应用
  /// 在 Mock 模式下，直接返回 Mock 数据
  Future<WechatLoginResponse?> login() async {
    try {
      _logDebug('🔄 发起微信登录...');

      if (MockConfig.useMockData) {
        // Mock 模式
        await _simulateNetworkDelay();
        final code = _generateMockCode();
        _logDebug('✅ 微信登录成功 (Mock)，授权码: $code');
        return WechatLoginResponse(
          code: code,
          userId: 'wx_user_${const Uuid().v4().substring(0, 8)}',
          nickname: '微信用户',
          avatarUrl: 'https://via.placeholder.com/150',
        );
      }

      // TODO: 真实环境中集成 fluwx 包
      // 需要的步骤：
      // 1. pubspec.yaml 添加 fluwx 包
      // 2. iOS 配置 URL Schemes
      // 3. Android 配置 WeChat SDK
      // 4. 调用 fluwx.sendWeChatAuth()
      
      _logDebug('⚠️ 微信 SDK 未集成，请将 APP_ID 设置为真实值并集成 fluwx 包');
      return null;
    } catch (e) {
      _logDebug('❌ 微信登录失败: $e');
      rethrow;
    }
  }

  /// 发起微信支付
  /// 在真实环境中，这会触发微信支付
  /// 在 Mock 模式下，直接返回 Mock 数据
  Future<WechatPaymentResponse?> pay({
    required String orderId,
    required double amount,
    required String description,
  }) async {
    try {
      _logDebug('🔄 发起微信支付...');
      _logDebug('   订单: $orderId');
      _logDebug('   金额: ¥$amount');
      _logDebug('   描述: $description');

      if (MockConfig.useMockData) {
        // Mock 模式 - 模拟支付成功
        await _simulateNetworkDelay();
        final transactionId = _generateMockTransactionId();
        _logDebug('✅ 微信支付成功 (Mock)，交易单号: $transactionId');
        return WechatPaymentResponse(
          success: true,
          transactionId: transactionId,
        );
      }

      // TODO: 真实环境中集成 fluwx 包
      // 需要的步骤：
      // 1. 从后端获取支付参数
      // 2. 调用 fluwx.pay() 
      // 3. 处理支付结果
      
      _logDebug('⚠️ 微信支付 SDK 未集成');
      return null;
    } catch (e) {
      _logDebug('❌ 微信支付失败: $e');
      return WechatPaymentResponse(
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
  String _generateMockTransactionId() {
    return 'mock_tx_${const Uuid().v4().substring(0, 20)}';
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
      print('[WechatService] $message');
    }
  }
}
