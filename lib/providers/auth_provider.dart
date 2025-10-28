import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promptify/models/user_model.dart';
import 'package:promptify/services/auth_service.dart';

/// 认证服务提供者
final authServiceProvider = Provider((ref) {
  return AuthService();
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
  Future<void> loginWithPhone(String phone, String smsCode) async {
    state = const AsyncValue.loading();
    try {
      final response = await _authService.loginWithPhone(phone, smsCode);
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
  Future<void> registerWithPhone(String phone, String smsCode, String? nickname) async {
    state = const AsyncValue.loading();
    try {
      final response = await _authService.registerWithPhone(phone, smsCode, nickname);
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
      final code = await _authService.getWechatAuthCode();
      if (code != null) {
        final response = await _authService.loginWithWeChat(code);
        if (response != null) {
          state = AsyncValue.data(response.user);
        } else {
          state = AsyncValue.error('微信登录失败', StackTrace.current);
        }
      } else {
        // 演示模式：没有原生SDK时的错误提示
        state = AsyncValue.error(
          '微信SDK未集成\n需要在原生代码中配置微信SDK\n'
          '详见项目文档：AUTH_INTEGRATION_GUIDE.md',
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
      final code = await _authService.getAlipayAuthCode();
      if (code != null) {
        final response = await _authService.loginWithAlipay(code);
        if (response != null) {
          state = AsyncValue.data(response.user);
        } else {
          state = AsyncValue.error('支付宝登录失败', StackTrace.current);
        }
      } else {
        // 演示模式：没有原生SDK时的错误提示
        state = AsyncValue.error(
          '支付宝SDK未集成\n需要在原生代码中配置支付宝SDK\n'
          '详见项目文档：AUTH_INTEGRATION_GUIDE.md',
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
