# 功能快速参考指南

## 📱 三种登录方式

### 1. 手机号短信登录
```dart
// 自动集成到 LoginScreen
// 用户流程：
// 1. 输入11位手机号
// 2. 点击"获取验证码"
// 3. 收到短信后输入验证码
// 4. 点击"登录/注册"

// 代码调用
final authService = ref.read(authServiceProvider);
await authService.loginWithPhone(
  phone: '+86 13800000000',
  smsCode: '123456',
);
```

### 2. 微信快速登录
```dart
// 点击"微信登录"按钮自动触发
// 用户流程：
// 1. 打开微信授权页面
// 2. 用户授权
// 3. 自动登录注册

// 代码调用
final authService = ref.read(authServiceProvider);
await authService.loginWithWeChat();
```

### 3. 支付宝快速登录
```dart
// 点击"支付宝登录"按钮自动触发
// 用户流程：
// 1. 打开支付宝授权页面
// 2. 用户授权
// 3. 自动登录注册

// 代码调用
final authService = ref.read(authServiceProvider);
await authService.loginWithAlipay();
```

---

## 💳 支付系统

### 创建支付订单
```dart
final paymentService = ref.read(paymentServiceProvider);

final result = await paymentService.createPaymentOrder(
  userId: 'user123',
  amount: 48.0,
  method: PaymentMethod.wechat, // 或 PaymentMethod.alipay
  productId: 'pro_version',
);

// 返回结果
print(result.orderId);        // 订单ID
print(result.paymentString);  // 支付签名串
```

### 查询订单状态
```dart
final status = await paymentService.queryOrderStatus('order123');
// 返回: 'pending', 'completed', 'failed' 等
```

### 确认支付
```dart
final result = await paymentService.confirmPayment('order123');
// 返回支付结果
```

---

## 👤 用户管理

### 获取当前用户信息
```dart
final user = ref.watch(currentUserProvider);

print(user?.userId);
print(user?.phone);
print(user?.nickname);
print(user?.isPaidUser);
```

### 检查登录状态
```dart
final isAuth = ref.watch(isAuthenticatedProvider);
if (isAuth) {
  // 已登录
} else {
  // 未登录
}
```

### 检查付费状态
```dart
final isPaid = ref.watch(isPaidUserProvider);
if (isPaid) {
  // 已付费，显示专业版功能
} else {
  // 未付费，显示升级提示
}
```

### 登出
```dart
final authService = ref.read(authServiceProvider);
await authService.logout();
```

---

## 🔐 Token 管理

Token 自动存储在安全存储中，无需手动管理：
```dart
// 自动完成的流程
// 1. 登录后自动保存 Token
// 2. 每次请求自动使用 Token
// 3. Token 过期自动刷新
// 4. 登出时自动清除 Token
```

---

## 🚀 路由使用

### 跳转到登录页面
```dart
context.push('/login');
// 或使用 Navigator
Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
```

### 跳转到支付页面
```dart
context.push('/payment');
// 或使用 Navigator
Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen()));
```

---

## 📋 数据模型

### User 模型
```dart
User(
  userId: '123',
  phone: '13800000000',
  wechatId: 'wechat_id',
  alipayId: 'alipay_id',
  nickname: '用户昵称',
  avatar: 'https://...',
  isAuthenticated: true,
  isPaidUser: false,
  createdAt: DateTime.now(),
  lastLoginAt: DateTime.now(),
)
```

### PaymentOrder 模型
```dart
PaymentOrder(
  orderId: 'order123',
  userId: 'user123',
  amount: 48.0,
  method: PaymentMethod.wechat,
  productId: 'pro_version',
  status: 'pending',
  createdAt: DateTime.now(),
  completedAt: null,
)
```

---

## 🛠️ 配置

### API 基础地址
修改这两个文件中的 `_baseUrl`：

```dart
// lib/services/auth_service.dart
static const String _baseUrl = 'YOUR_BACKEND_URL';

// lib/services/payment_service.dart
static const String _baseUrl = 'YOUR_BACKEND_URL';
```

### 手机号验证规则
当前支持中国大陆手机号：
- 必须 11 位数字
- 必须以 1 开头
- 使用 `_isValidPhone` 方法验证

---

## 🐛 常见问题解决

### 1. Token 过期了怎么办？
自动处理，`AuthService` 会自动刷新。

### 2. 离线状态下能登录吗？
不能，需要网络连接。可以添加离线缓存逻辑。

### 3. 如何自定义登录界面？
修改 `lib/ui/screens/login_screen.dart` 中的 UI 部分。

### 4. 支付失败后怎么重试？
调用 `createPaymentOrder` 创建新订单，再次支付。

### 5. 如何添加其他登录方式？
在 `AuthService` 中添加新方法，然后在 `LoginScreen` 中添加按钮。

---

## 📞 所需 API 端点

### 认证相关
```
POST /auth/send-sms             - 发送短信验证码
POST /auth/login-phone          - 手机号登录/注册
POST /auth/login-wechat         - 微信登录
POST /auth/login-alipay         - 支付宝登录
POST /auth/refresh-token        - 刷新Token
POST /auth/logout               - 登出
```

### 支付相关
```
POST /payment/create-order      - 创建支付订单
GET  /payment/order/:orderId    - 查询订单状态
POST /payment/confirm           - 确认支付
```

---

## 🔗 相关文件速查

| 功能 | 文件位置 |
|------|--------|
| 登录逻辑 | `lib/services/auth_service.dart` |
| 支付逻辑 | `lib/services/payment_service.dart` |
| 登录UI | `lib/ui/screens/login_screen.dart` |
| 支付UI | `lib/ui/screens/payment_screen.dart` |
| 用户状态 | `lib/providers/auth_provider.dart` |
| 支付状态 | `lib/providers/payment_provider.dart` |
| 用户模型 | `lib/models/user_model.dart` |
| 支付模型 | `lib/models/payment_model.dart` |

---

## 💡 最佳实践

1. **始终使用 Provider 访问状态**
   ```dart
   // 好
   final user = ref.watch(currentUserProvider);
   
   // 不好
   final user = await authService.getCurrentUser();
   ```

2. **错误处理**
   ```dart
   try {
     await authService.loginWithPhone(phone: phone, smsCode: code);
   } catch (e) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('登录失败: $e')),
     );
   }
   ```

3. **加载状态处理**
   ```dart
   final userAsync = ref.watch(currentUserProvider);
   
   userAsync.when(
     data: (user) => Text(user?.nickname ?? '未登录'),
     loading: () => CircularProgressIndicator(),
     error: (err, stack) => Text('错误: $err'),
   );
   ```

---

**最后更新**: 2024年10月28日  
**版本**: 1.0.0  
**状态**: 已发布
