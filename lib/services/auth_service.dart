import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:promptify/models/user_model.dart';
import 'package:uuid/uuid.dart';

/// 认证服务
/// 处理用户登录、注册、Token 管理等
class AuthService {
  /// 后端 API 基础 URL（需要修改为您的实际地址）
  static const String _baseUrl = 'https://your-api.example.com/api';
  
  late final Dio _dio;
  late final FlutterSecureStorage _secureStorage;
  
  AuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
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
      ),
    );
  }

  /// 发送短信验证码
  Future<bool> sendSmsCode(String phone) async {
    try {
      if (!_isValidPhone(phone)) {
        throw Exception('Invalid phone number');
      }

      final response = await _dio.post(
        '/auth/send-sms',
        data: {'phone': phone},
      );

      if (response.statusCode == 200) {
        print('SMS code sent to $phone');
        return true;
      }
      return false;
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }

  /// 手机号 + 短信码登录
  Future<LoginResponse?> loginWithPhone(String phone, String smsCode) async {
    try {
      final response = await _dio.post(
        '/auth/login-phone',
        data: {
          'phone': phone,
          'smsCode': smsCode,
        },
      );

      if (response.statusCode == 200) {
        final loginResp = LoginResponse.fromJson(response.data);
        
        await _saveTokens(loginResp.accessToken, loginResp.refreshToken);
        await _saveUser(loginResp.user);
        
        return loginResp;
      }
      return null;
    } catch (e) {
      print('Error logging in with phone: $e');
      return null;
    }
  }

  /// 手机号注册
  Future<LoginResponse?> registerWithPhone(
    String phone,
    String smsCode,
    String? nickname,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register-phone',
        data: {
          'phone': phone,
          'smsCode': smsCode,
          'nickname': nickname ?? 'User_${const Uuid().v4().substring(0, 8)}',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final loginResp = LoginResponse.fromJson(response.data);
        
        await _saveTokens(loginResp.accessToken, loginResp.refreshToken);
        await _saveUser(loginResp.user);
        
        return loginResp;
      }
      return null;
    } catch (e) {
      print('Error registering with phone: $e');
      return null;
    }
  }

  /// 获取微信登录授权码
  Future<String?> getWechatAuthCode() async {
    try {
      print('获取微信授权码...');
      // TODO: 需要在原生代码中实现 WeChat SDK 集成
      return null;
    } catch (e) {
      print('Error getting WeChat auth code: $e');
      return null;
    }
  }

  /// 使用微信授权码登录
  Future<LoginResponse?> loginWithWeChat(String code) async {
    try {
      final response = await _dio.post(
        '/auth/login-wechat',
        data: {'code': code},
      );

      if (response.statusCode == 200) {
        final loginResp = LoginResponse.fromJson(response.data);
        
        await _saveTokens(loginResp.accessToken, loginResp.refreshToken);
        await _saveUser(loginResp.user);
        
        return loginResp;
      }
      return null;
    } catch (e) {
      print('Error logging in with WeChat: $e');
      return null;
    }
  }

  /// 获取支付宝授权码
  Future<String?> getAlipayAuthCode() async {
    try {
      print('获取支付宝授权码...');
      // TODO: 需要在原生代码中实现 Alipay SDK 集成
      return null;
    } catch (e) {
      print('Error getting Alipay auth code: $e');
      return null;
    }
  }

  /// 使用支付宝授权码登录
  Future<LoginResponse?> loginWithAlipay(String code) async {
    try {
      final response = await _dio.post(
        '/auth/login-alipay',
        data: {'code': code},
      );

      if (response.statusCode == 200) {
        final loginResp = LoginResponse.fromJson(response.data);
        
        await _saveTokens(loginResp.accessToken, loginResp.refreshToken);
        await _saveUser(loginResp.user);
        
        return loginResp;
      }
      return null;
    } catch (e) {
      print('Error logging in with Alipay: $e');
      return null;
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

  /// 获取当前用户信息
  Future<User?> getCurrentUser() async {
    final userJson = await _secureStorage.read(key: 'user');
    if (userJson != null) {
      try {
        return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing user: $e');
      }
    }
    return null;
  }
  
  /// User 的 fromJson 方法
  static User _userFromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as String,
      phone: json['phone'] as String?,
      wechatId: json['wechatId'] as String?,
      alipayId: json['alipayId'] as String?,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      isAuthenticated: json['isAuthenticated'] as bool? ?? false,
      isPaidUser: json['isPaidUser'] as bool? ?? false,
      createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : null,
      lastLoginAt: json['lastLoginAt'] != null
        ? DateTime.parse(json['lastLoginAt'] as String)
        : null,
    );
  }

  /// 刷新 Token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'] as String;
        final newRefreshToken = response.data['refreshToken'] as String;
        
        await _saveTokens(newAccessToken, newRefreshToken);
        return true;
      }
      return false;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      print('Error logging out: $e');
    } finally {
      await Future.wait([
        _secureStorage.delete(key: 'accessToken'),
        _secureStorage.delete(key: 'refreshToken'),
        _secureStorage.delete(key: 'user'),
      ]);
    }
  }

  /// 验证手机号格式（中国）
  bool _isValidPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleanPhone.length == 11 && cleanPhone.startsWith('1');
  }
}
