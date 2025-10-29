import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:promptify/models/user_model.dart';
import 'package:promptify/core/constants.dart';
import 'package:uuid/uuid.dart';

/// 认证服务 - 处理用户登录、注册、Token 管理等
class AuthService {
  late final Dio _dio;
  late final FlutterSecureStorage _secureStorage;
  
  /// Token 过期时间戳
  DateTime? _tokenExpireTime;

  AuthService() {
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
          final token = await getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // 处理 401 错误（Token 过期）
          if (error.response?.statusCode == 401) {
            final success = await refreshToken();
            if (success) {
              // 重试原始请求
              return handler.resolve(await _dio.request(
                error.requestOptions.path,
                options: Options(
                  method: error.requestOptions.method,
                  headers: error.requestOptions.headers,
                ),
              ));
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// 手机号 + 密码登录
  Future<LoginResponse?> loginWithPhone(String phone, String password) async {
    try {
      if (MockConfig.useMockData) {
        // Mock 数据模式
        await _simulateNetworkDelay();
        return _generateMockLoginResponse(phone);
      }

      final response = await _dio.post(
        ApiEndpoints.loginPhone,
        data: {
          'phone': phone,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final loginResp = LoginResponse.fromJson(response.data);
        
        await _saveTokens(loginResp.accessToken, loginResp.refreshToken);
        await _saveUser(loginResp.user);
        _updateTokenExpireTime();
        
        _logDebug('✅ 登录成功: $phone');
        return loginResp;
      }
      return null;
    } catch (e) {
      _logDebug('❌ 登录失败: $e');
      rethrow;
    }
  }

  /// 手机号 + 密码注册
  Future<LoginResponse?> registerWithPhone(
    String phone,
    String password,
    String? nickname,
  ) async {
    try {
      if (MockConfig.useMockData) {
        // Mock 数据模式
        await _simulateNetworkDelay();
        return _generateMockLoginResponse(
          phone,
          nickname: nickname ?? 'User_${const Uuid().v4().substring(0, 8)}',
        );
      }

      final response = await _dio.post(
        ApiEndpoints.registerPhone,
        data: {
          'phone': phone,
          'password': password,
          'nickname': nickname ?? 'User_${const Uuid().v4().substring(0, 8)}',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final loginResp = LoginResponse.fromJson(response.data);
        
        await _saveTokens(loginResp.accessToken, loginResp.refreshToken);
        await _saveUser(loginResp.user);
        _updateTokenExpireTime();
        
        _logDebug('✅ 注册成功: $phone');
        return loginResp;
      }
      return null;
    } catch (e) {
      _logDebug('❌ 注册失败: $e');
      rethrow;
    }
  }

  /// 微信登录
  Future<LoginResponse?> loginWithWeChat(String code) async {
    try {
      if (MockConfig.useMockData) {
        // Mock 数据模式
        await _simulateNetworkDelay();
        return _generateMockLoginResponse('wechat_user_${const Uuid().v4().substring(0, 8)}');
      }

      final response = await _dio.post(
        ApiEndpoints.loginWeChat,
        data: {'code': code},
      );

      if (response.statusCode == 200) {
        final loginResp = LoginResponse.fromJson(response.data);
        
        await _saveTokens(loginResp.accessToken, loginResp.refreshToken);
        await _saveUser(loginResp.user);
        _updateTokenExpireTime();
        
        _logDebug('✅ 微信登录成功');
        return loginResp;
      }
      return null;
    } catch (e) {
      _logDebug('❌ 微信登录失败: $e');
      rethrow;
    }
  }

  /// 支付宝登录
  Future<LoginResponse?> loginWithAlipay(String code) async {
    try {
      if (MockConfig.useMockData) {
        // Mock 数据模式
        await _simulateNetworkDelay();
        return _generateMockLoginResponse('alipay_user_${const Uuid().v4().substring(0, 8)}');
      }

      final response = await _dio.post(
        ApiEndpoints.loginAlipay,
        data: {'code': code},
      );

      if (response.statusCode == 200) {
        final loginResp = LoginResponse.fromJson(response.data);
        
        await _saveTokens(loginResp.accessToken, loginResp.refreshToken);
        await _saveUser(loginResp.user);
        _updateTokenExpireTime();
        
        _logDebug('✅ 支付宝登录成功');
        return loginResp;
      }
      return null;
    } catch (e) {
      _logDebug('❌ 支付宝登录失败: $e');
      rethrow;
    }
  }

  /// 获取 Access Token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'accessToken');
  }

  /// 获取 Refresh Token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refreshToken');
  }

  /// Token 是否需要刷新
  bool _isTokenNeedRefresh() {
    if (_tokenExpireTime == null) return false;
    final now = DateTime.now();
    final refreshThreshold = Duration(minutes: AppConfig.tokenRefreshBeforeMinutes);
    return _tokenExpireTime!.difference(now) < refreshThreshold;
  }

  /// 刷新 Token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      if (MockConfig.useMockData) {
        // Mock 数据模式
        await _simulateNetworkDelay();
        final newAccessToken = _generateMockToken();
        final newRefreshToken = _generateMockToken();
        await _saveTokens(newAccessToken, newRefreshToken);
        _updateTokenExpireTime();
        _logDebug('✅ Token 刷新成功（Mock）');
        return true;
      }

      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'] as String;
        final newRefreshToken = response.data['refreshToken'] as String;
        
        await _saveTokens(newAccessToken, newRefreshToken);
        _updateTokenExpireTime();
        _logDebug('✅ Token 刷新成功');
        return true;
      }
      return false;
    } catch (e) {
      _logDebug('❌ Token 刷新失败: $e');
      return false;
    }
  }

  /// 获取当前用户信息
  Future<User?> getCurrentUser() async {
    final userJson = await _secureStorage.read(key: 'user');
    if (userJson != null) {
      try {
        return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      } catch (e) {
        _logDebug('❌ 解析用户信息失败: $e');
      }
    }
    return null;
  }

  /// 保存 Token
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await Future.wait([
      _secureStorage.write(key: 'accessToken', value: accessToken),
      _secureStorage.write(key: 'refreshToken', value: refreshToken),
    ]);
  }

  /// 保存用户信息
  Future<void> _saveUser(User user) async {
    final userMap = {
      'userId': user.userId,
      'phone': user.phone,
      'wechatId': user.wechatId,
      'alipayId': user.alipayId,
      'nickname': user.nickname,
      'avatar': user.avatar,
      'isAuthenticated': user.isAuthenticated,
      'isPaidUser': user.isPaidUser,
      'createdAt': user.createdAt?.toIso8601String(),
      'lastLoginAt': user.lastLoginAt?.toIso8601String(),
    };
    
    await _secureStorage.write(
      key: 'user',
      value: jsonEncode(userMap),
    );
  }

  /// 登出
  Future<void> logout() async {
    try {
      if (!MockConfig.useMockData) {
        await _dio.post(ApiEndpoints.logout);
      }
    } catch (e) {
      _logDebug('❌ 登出请求失败: $e');
    } finally {
      await Future.wait([
        _secureStorage.delete(key: 'accessToken'),
        _secureStorage.delete(key: 'refreshToken'),
        _secureStorage.delete(key: 'user'),
      ]);
      _tokenExpireTime = null;
      _logDebug('✅ 已登出');
    }
  }

  // ===== Mock 数据生成方法 =====

  /// 更新 Token 过期时间
  void _updateTokenExpireTime() {
    _tokenExpireTime = DateTime.now().add(
      Duration(hours: AppConfig.tokenExpirationHours),
    );
  }

  /// 生成 Mock Token
  String _generateMockToken() {
    return 'mock_token_${const Uuid().v4()}';
  }

  /// 生成 Mock 登录响应
  LoginResponse _generateMockLoginResponse(String userId, {String? nickname}) {
    final now = DateTime.now();
    final user = User(
      userId: userId,
      phone: '$userId@example.com',
      nickname: nickname ?? 'Test User',
      avatar: 'https://via.placeholder.com/150',
      isAuthenticated: true,
      isPaidUser: false,
      createdAt: now,
      lastLoginAt: now,
    );

    return LoginResponse(
      accessToken: _generateMockToken(),
      refreshToken: _generateMockToken(),
      user: user,
    );
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
      print('[AuthService] $message');
    }
  }
}
