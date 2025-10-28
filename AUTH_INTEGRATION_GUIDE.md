# 认证和支付功能集成指南

## 概述

本项目已集成以下功能：

✅ **手机号快速登录/注册**
✅ **微信快速登录**（框架已准备）
✅ **支付宝快速登录**（框架已准备）
✅ **微信支付**（框架已准备）
✅ **支付宝支付**（框架已准备）
✅ **用户信息管理**
✅ **Token 管理和刷新**

---

## 项目结构

### 新增文件

```
lib/
├── models/
│   ├── user_model.dart           # 用户数据模型（Freezed）
│   └── payment_model.dart        # 支付数据模型（Freezed）
├── providers/
│   ├── auth_provider.dart        # 用户认证 Provider（Riverpod）
│   └── payment_provider.dart     # 支付 Provider（Riverpod）
├── services/
│   ├── auth_service.dart         # 认证业务逻辑服务
│   └── payment_service.dart      # 支付业务逻辑服务
└── ui/
    └── screens/
        ├── login_screen.dart     # 登录屏幕
        ├── payment_screen.dart   # 支付屏幕
        └── profile_screen.dart   # 已更新：集成登录功能
```

---

## 核心功能说明

### 1. 手机号登录/注册

**流程：**
1. 用户输入手机号
2. 点击"获取验证码"
3. 后端发送 SMS 验证码
4. 用户输入验证码
5. 登录或注册成功

**相关代码：**
- `AuthService.sendSmsCode()` - 发送短信码
- `AuthService.loginWithPhone()` - 手机号登录
- `AuthService.registerWithPhone()` - 手机号注册
- `LoginScreen` - UI 界面

### 2. 微信登录（框架已准备）

**需要的原生集成：**

**Android（kotlin）：**
```kotlin
// 在 MainActivity 中调用微信 SDK
WXAPIFactory.createWXAPI(this, "wxXXXXXXXXXXXXXX").registerApp(...)
```

**iOS（Swift）：**
```swift
// 在 AppDelegate 中配置
WechatSDK.registerApp(...)
```

**Dart 代码已准备：**
- `AuthService.getWechatAuthCode()` - 获取微信授权码
- `AuthService.loginWithWeChat()` - 微信登录
- `LoginScreen` 中的微信登录按钮

### 3. 支付宝登录（框架已准备）

类似微信登录，需要原生集成。

### 4. 微信支付（框架已准备）

**相关代码：**
- `PaymentService.createOrder()` - 创建支付订单
- `PaymentScreen` - 支付界面

### 5. 支付宝支付（框架已准备）

类似微信支付，需要原生集成。

---

## 后端 API 要求

应用期望以下后端 API 端点：

### 认证相关

**1. 发送短信码**
```
POST /api/auth/send-sms
Body: { "phone": "13800138000" }
Response: { "success": true }
```

**2. 手机号登录**
```
POST /api/auth/login-phone
Body: {
  "phone": "13800138000",
  "smsCode": "123456"
}
Response: {
  "accessToken": "jwt_token",
  "refreshToken": "refresh_token",
  "user": { ... }
}
```

**3. 手机号注册**
```
POST /api/auth/register-phone
Body: {
  "phone": "13800138000",
  "smsCode": "123456",
  "nickname": "用户名"
}
Response: { ... }
```

**4. 微信登录**
```
POST /api/auth/login-wechat
Body: { "code": "wechat_auth_code" }
Response: { ... }
```

**5. 支付宝登录**
```
POST /api/auth/login-alipay
Body: { "code": "alipay_auth_code" }
Response: { ... }
```

**6. 刷新 Token**
```
POST /api/auth/refresh-token
Body: { "refreshToken": "refresh_token" }
Response: {
  "accessToken": "new_jwt_token",
  "refreshToken": "new_refresh_token"
}
```

### 支付相关

**1. 创建支付订单**
```
POST /api/payment/create-order
Body: {
  "userId": "user_id",
  "amount": 48.00,
  "method": "wechat" | "alipay",
  "productId": "pro"
}
Response: {
  "orderId": "order_123",
  "paymentString": "支付宝/微信签名串",
  "method": "wechat",
  "expiresAt": "2024-01-01T00:00:00Z"
}
```

**2. 查询订单**
```
GET /api/payment/order/{orderId}
Response: { ... }
```

**3. 确认支付**
```
POST /api/payment/confirm
Body: { "orderId": "order_123" }
Response: { "success": true }
```

---

## 集成清单

### 必须完成的工作

- [ ] 修改 `AuthService._baseUrl` 为实际后端地址
- [ ] 修改 `PaymentService._baseUrl` 为实际后端地址
- [ ] 实现后端 API 端点
- [ ] 集成微信 SDK（原生代码）
- [ ] 集成支付宝 SDK（原生代码）
- [ ] 在 `AuthService.getWechatAuthCode()` 中调用原生微信方法
- [ ] 在 `AuthService.getAlipayAuthCode()` 中调用原生支付宝方法
- [ ] 测试完整的登录和支付流程

### 可选的优化

- [ ] 添加生物识别认证（指纹/人脸）
- [ ] 添加社交媒体登录（QQ、微博等）
- [ ] 实现账户注销功能
- [ ] 添加用户头像上传
- [ ] 实现两步验证

---

## 使用示例

### 登录屏幕

```dart
// 访问登录屏幕
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const LoginScreen()),
);
```

### 支付屏幕

```dart
// 访问支付屏幕
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const PaymentScreen()),
);
```

### 获取当前用户

```dart
// 在任何 ConsumerWidget 中
final userAsync = ref.watch(currentUserProvider);

userAsync.when(
  data: (user) {
    if (user != null) {
      print('已登录: ${user.nickname}');
    } else {
      print('未登录');
    }
  },
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('错误: $err'),
);
```

### 检查是否已付费

```dart
// 在任何 ConsumerWidget 中
final isPaidUser = ref.watch(isPaidUserProvider);

if (isPaidUser) {
  // 显示专业版功能
} else {
  // 显示升级提示
}
```

---

## 调试

### 查看已保存的用户信息

```dart
final authService = AuthService();
final user = await authService.getCurrentUser();
print('Current user: $user');
```

### 查看 Token

```dart
final authService = AuthService();
final token = await authService.getAccessToken();
print('Access token: $token');
```

### 清除本地存储

```dart
final authService = AuthService();
await authService.logout();
```

---

## 常见问题

**Q: 微信/支付宝登录一直返回 null？**
A: 需要在原生代码中实现 `getWechatAuthCode()` 和 `getAlipayAuthCode()`。目前这两个方法只是占位符。

**Q: Token 过期了怎么办？**
A: 应用会自动调用 `AuthService.refreshToken()` 来刷新 Token。如果刷新失败，用户需要重新登录。

**Q: 如何支持更多的登录方式？**
A: 在 `AuthService` 中添加新的 `loginWith*()` 方法，并在 `LoginScreen` 中添加对应的 UI 按钮。

**Q: 支付后用户信息没有更新？**
A: 支付成功后需要调用后端 API 更新用户的 `isPaidUser` 字段，然后调用 `ref.invalidate(currentUserProvider)` 来刷新状态。

---

## 技术细节

### 依赖包

- `flutter_secure_storage` - 安全存储 Token
- `dio` - 网络请求
- `freezed_annotation` - 数据类生成
- `flutter_riverpod` - 状态管理
- `intl_phone_number_input` - 手机号输入
- `sms_autofill` - 短信自动填充

### 状态管理

- `currentUserProvider` - 当前用户状态
- `isAuthenticatedProvider` - 是否已登录
- `isPaidUserProvider` - 是否是付费用户
- `authServiceProvider` - 认证服务实例
- `paymentServiceProvider` - 支付服务实例

### 数据存储

- Token 存储在 `flutter_secure_storage` 中
- 用户信息存储在内存中
- 所有持久化操作都在 `AuthService` 中处理

---

## 下一步

1. **实现后端 API** - 这是必须的第一步
2. **集成原生 SDK** - 微信和支付宝的原生集成
3. **测试** - 完整的端到端测试
4. **上线** - 在 App Store 和 Google Play 上配置产品

---

**创建时间**: 2024年10月28日  
**最后更新**: 2024年10月28日
