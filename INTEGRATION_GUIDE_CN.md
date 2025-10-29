# 服务集成指南

## 📚 概述

本指南说明如何在现有的 Flutter 应用中集成已实现的认证、支付、微信和支付宝服务。

---

## 🔌 快速集成步骤

### 第1步：在 Provider 中创建服务实例

```dart
// lib/providers/services_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promptify/services/auth_service.dart';
import 'package:promptify/services/payment_service.dart';
import 'package:promptify/services/wechat_service.dart';
import 'package:promptify/services/alipay_service.dart';

// 认证服务
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// 支付服务
final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

// 微信服务
final wechatServiceProvider = Provider<WechatService>((ref) {
  return WechatService();
});

// 支付宝服务
final alipayServiceProvider = Provider<AlipayService>((ref) {
  return AlipayService();
});
```

### 第2步：在登录屏幕中使用认证服务

```dart
// lib/ui/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promptify/providers/services_provider.dart';
import 'package:promptify/services/auth_service.dart';
import 'package:promptify/services/wechat_service.dart';
import 'package:promptify/services/alipay_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (phone.isEmpty || password.isEmpty) {
      _showSnackBar('请输入手机号和密码');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.loginWithPhone(phone, password);

      if (response != null && mounted) {
        _showSnackBar('登录成功');
        // 返回上一个屏幕
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('登录失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleWechatLogin() async {
    setState(() => _isLoading = true);
    try {
      final wechatService = ref.read(wechatServiceProvider);
      final response = await wechatService.login();

      if (response != null && mounted) {
        // 使用授权码向后端换取 Token
        final authService = ref.read(authServiceProvider);
        final loginResponse = await authService.loginWithWeChat(response.code);

        if (loginResponse != null) {
          _showSnackBar('微信登录成功');
          Navigator.pop(context);
        }
      }
    } catch (e) {
      _showSnackBar('微信登录失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAlipayLogin() async {
    setState(() => _isLoading = true);
    try {
      final alipayService = ref.read(alipayServiceProvider);
      final response = await alipayService.login();

      if (response != null && mounted) {
        // 使用授权码向后端换取 Token
        final authService = ref.read(authServiceProvider);
        final loginResponse = await authService.loginWithAlipay(response.code);

        if (loginResponse != null) {
          _showSnackBar('支付宝登录成功');
          Navigator.pop(context);
        }
      }
    } catch (e) {
      _showSnackBar('支付宝登录失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(message: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                label: Text('手机号'),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                label: Text('密码'),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('登录'),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _isLoading ? null : _handleWechatLogin,
                  icon: const Icon(Icons.chat),
                  tooltip: '微信登录',
                ),
                IconButton(
                  onPressed: _isLoading ? null : _handleAlipayLogin,
                  icon: const Icon(Icons.payment),
                  tooltip: '支付宝登录',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### 第3步：在支付屏幕中使用支付服务

```dart
// lib/ui/screens/payment_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promptify/providers/services_provider.dart';
import 'package:promptify/services/payment_service.dart';
import 'package:promptify/services/wechat_service.dart';
import 'package:promptify/services/alipay_service.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String userId;

  const PaymentScreen({required this.userId});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isLoading = false;
  String? _orderId;

  Future<void> _handleWechatPayment() async {
    setState(() => _isLoading = true);
    try {
      final paymentService = ref.read(paymentServiceProvider);

      // 创建订单
      final order = await paymentService.createOrder(
        userId: widget.userId,
        amount: 48.0,
        productId: 'pro',
        productName: 'Promptify Pro',
        method: PaymentMethod.wechat,
      );

      if (order != null && mounted) {
        setState(() => _orderId = order.orderId);

        // 发起微信支付
        final wechatService = ref.read(wechatServiceProvider);
        final paymentResult = await wechatService.pay(
          orderId: order.orderId,
          amount: order.amount,
          description: order.productName,
        );

        if (paymentResult != null && paymentResult.success && mounted) {
          // 确认支付
          await paymentService.confirmPayment(order.orderId);
          _showSnackBar('支付成功');
          Navigator.pop(context, true);
        } else {
          _showSnackBar('支付失败: ${paymentResult?.errorMessage}');
        }
      }
    } catch (e) {
      _showSnackBar('支付错误: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAlipayPayment() async {
    setState(() => _isLoading = true);
    try {
      final paymentService = ref.read(paymentServiceProvider);

      // 创建订单
      final order = await paymentService.createOrder(
        userId: widget.userId,
        amount: 48.0,
        productId: 'pro',
        productName: 'Promptify Pro',
        method: PaymentMethod.alipay,
      );

      if (order != null && mounted) {
        setState(() => _orderId = order.orderId);

        // 发起支付宝支付
        final alipayService = ref.read(alipayServiceProvider);
        final paymentResult = await alipayService.pay(
          orderId: order.orderId,
          amount: order.amount,
          description: order.productName,
        );

        if (paymentResult != null && paymentResult.success && mounted) {
          // 确认支付
          await paymentService.confirmPayment(order.orderId);
          _showSnackBar('支付成功');
          Navigator.pop(context, true);
        } else {
          _showSnackBar('支付失败: ${paymentResult?.errorMessage}');
        }
      }
    } catch (e) {
      _showSnackBar('支付错误: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(message: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('选择支付方式')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Promptify Pro - ¥48.00',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleWechatPayment,
                icon: const Icon(Icons.chat),
                label: const Text('微信支付'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleAlipayPayment,
                icon: const Icon(Icons.payment),
                label: const Text('支付宝支付'),
              ),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 32),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              if (_orderId != null)
                Text('订单: $_orderId'),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## 🎯 关键集成点

### 1. 在 Provider 中创建服务
```dart
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
```

### 2. 在 Widget 中使用服务
```dart
final authService = ref.read(authServiceProvider);
await authService.loginWithPhone(phone, password);
```

### 3. 处理错误和加载状态
```dart
try {
  // 调用服务
} catch (e) {
  // 显示错误
} finally {
  // 更新加载状态
}
```

---

## 🔍 Debug 日志位置

打开 Flutter 控制台查看日志：

```bash
flutter run

# 输出示例：
# [AuthService] ✅ 登录成功: user@example.com
# [PaymentService] ✅ 订单创建成功: ORDER_xxxxx
# [WechatService] ✅ 微信登录成功 (Mock)
```

---

## 🔐 常见问题

### Q: 为什么登录没有反应？
A: 检查 Debug 控制台是否有错误日志。确保 Mock 模式启用（MockConfig.useMockData = true）。

### Q: 如何切换到真实 API？
A: 修改 `lib/core/constants.dart` 中的配置：
```dart
static const bool useMockData = false;
static const String baseUrl = 'https://your-api.com/api';
```

### Q: 微信/支付宝支付返回 null？
A: 这是正常的，因为 APP_ID 还是占位符。当你获得真实 APP_ID 后，集成真实 SDK。

### Q: 如何查看保存的 Token？
A: Token 保存在 flutter_secure_storage 中（加密存储）。你可以在 AuthService 中添加调试代码查看。

---

## ✅ 验收清单

- [ ] 服务创建成功（无编译错误）
- [ ] 登录功能可用（Mock 数据返回）
- [ ] 支付功能可用（Mock 数据返回）
- [ ] 微信/支付宝框架就位
- [ ] Debug 日志正常输出
- [ ] Token 正确保存和刷新
- [ ] 错误处理完整
- [ ] UI 集成完成

---

## 📞 后续支持

当你需要进一步扩展功能时：

1. **数据持久化**：集成 Drift ORM 保存订单历史
2. **单元测试**：为服务编写测试用例
3. **真实 SDK**：按照各服务文件的 TODO 集成真实 SDK
4. **后端集成**：修改 API 基础 URL 连接真实后端

---

**准备好了吗？开始集成吧！** 🚀

