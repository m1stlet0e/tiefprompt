import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promptify/models/user_model.dart';
import 'package:promptify/services/auth_service.dart';
import 'package:promptify/services/wechat_service.dart';
import 'package:promptify/services/alipay_service.dart';

/// 认证服务提供者
final authServiceProvider = Provider((ref) {
  return AuthService();
});

/// 微信服务提供者
final wechatServiceProvider = Provider((ref) {
  return WechatService();
});

/// 支付宝服务提供者
final alipayServiceProvider = Provider((ref) {
  return AlipayService();
});

/// 当前用户状态
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AsyncValue<User?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return CurrentUserNotifier(authService);
});

/// 认证状态
final isAuthenticatedProvider = Provider((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});

/// 是否是付费用户
final isPaidUserProvider = Provider((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.maybeWhen(
    data: (user) => user?.isPaidUser ?? false,
    orElse: () => false,
  );
});

/// 当前用户状态管理器
class CurrentUserNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  CurrentUserNotifier(this._authService) : super(const AsyncValue.loading()) {
    _initialize();
  }

  /// 初始化，加载本地用户信息
  Future<void> _initialize() async {
    try {
      final user = await _authService.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// 使用手机号登录
  Future<void> loginWithPhone(String phone, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await _authService.loginWithPhone(phone, password);
      if (response != null) {
        state = AsyncValue.data(response.user);
      } else {
        state = AsyncValue.error('Login failed', StackTrace.current);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// 使用手机号注册
  Future<void> registerWithPhone(String phone, String password, String? nickname) async {
    state = const AsyncValue.loading();
    try {
      final response = await _authService.registerWithPhone(phone, password, nickname);
      if (response != null) {
        state = AsyncValue.data(response.user);
      } else {
        state = AsyncValue.error('Registration failed', StackTrace.current);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// 使用微信登录
  Future<void> loginWithWeChat() async {
    state = const AsyncValue.loading();
    try {
      final wechatService = WechatService();
      final response = await wechatService.login();
      if (response != null) {
        final authService = _authService;
        final loginResponse = await authService.loginWithWeChat(response.code);
        if (loginResponse != null) {
          state = AsyncValue.data(loginResponse.user);
        } else {
          state = AsyncValue.error('微信登录失败', StackTrace.current);
        }
      } else {
        state = AsyncValue.error(
          '微信登录失败\n请确保已获取 App ID 并配置正确',
          StackTrace.current
        );
      }
    } catch (e) {
      state = AsyncValue.error('微信登录出错: $e', StackTrace.current);
    }
  }

  /// 使用支付宝登录
  Future<void> loginWithAlipay() async {
    state = const AsyncValue.loading();
    try {
      final alipayService = AlipayService();
      final response = await alipayService.login();
      if (response != null) {
        final authService = _authService;
        final loginResponse = await authService.loginWithAlipay(response.code);
        if (loginResponse != null) {
          state = AsyncValue.data(loginResponse.user);
        } else {
          state = AsyncValue.error('支付宝登录失败', StackTrace.current);
        }
      } else {
        state = AsyncValue.error(
          '支付宝登录失败\n请确保已获取 App ID 并配置正确',
          StackTrace.current
        );
      }
    } catch (e) {
      state = AsyncValue.error('支付宝登录出错: $e', StackTrace.current);
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      await _authService.logout();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
