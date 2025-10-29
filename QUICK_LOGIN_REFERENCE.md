# 登录/注册页面 - 快速参考

## 关键改变

### 从SMS验证码 → 密码登录

| 方面 | 旧方案 | 新方案 |
|-----|-------|--------|
| 登录方式 | 短信验证码 + 手机号 | 密码 + 手机号/邮箱/用户名 |
| 页面结构 | 单一登录页面 | 登录/注册标签页切换 |
| 注册流程 | 手机号 + SMS | 手机号 + 密码 + 昵称(可选) |
| 密码管理 | 不支持 | 支持密码可见性切换 |
| 第三方登录 | 支持 | 支持 |

## 核心代码片段

### 登录功能
```dart
// lib/ui/screens/login_screen.dart
Future<void> _handleLogin() async {
  final phone = _loginPhoneController.text.trim();
  final password = _loginPasswordController.text;
  
  await ref.read(currentUserProvider.notifier)
      .loginWithPhone(phone, password);
}
```

### 注册功能
```dart
Future<void> _handleRegister() async {
  final phone = _registerPhoneController.text.trim();
  final password = _registerPasswordController.text;
  final nickname = _registerNicknameController.text.trim();
  
  await ref.read(currentUserProvider.notifier)
      .registerWithPhone(phone, password, 
                        nickname.isEmpty ? null : nickname);
}
```

## 文件变更摘要

### 1. login_screen.dart
- 完全重写
- 添加TabController用于页面切换
- 实现密码登录和注册
- 优化UI设计

### 2. auth_service.dart
```dart
// 改变前
loginWithPhone(String phone, String smsCode)
registerWithPhone(String phone, String smsCode, String? nickname)

// 改变后
loginWithPhone(String phone, String password)
registerWithPhone(String phone, String password, String? nickname)
```

### 3. auth_provider.dart
- 更新方法签名以匹配服务层
- 参数从`smsCode`改为`password`

## UI特性

### 视觉设计
- 动态主题色（使用`theme.primaryColor`）
- 渐变登录按钮 (48pt高度, 24pt圆角)
- 社交登录按钮 (56x56pt, 16pt圆角)
- 密码显示/隐藏切换

### 交互设计
- 标签页无缝切换
- 加载状态显示
- 实时错误提示
- 注册成功自动返回登录页
- 键盘安全处理

## 后端需求

### API端点变更

**登录** - `POST /auth/login-phone`
```json
{
  "phone": "string",      // 手机号/用户名/邮箱
  "password": "string"    // 密码
}
```

**注册** - `POST /auth/register-phone`
```json
{
  "phone": "string",      // 手机号/用户名/邮箱
  "password": "string",   // 密码
  "nickname": "string"    // 昵称（可选）
}
```

## 主题色应用

所有主要UI元素都使用`theme.primaryColor`：
- 标签栏指示器
- 登录按钮
- 密码可见按钮
- 链接文本颜色

当用户在设置中更改主题色时，登录页面会自动更新。

## 安全特性

✓ 密码在输入时隐藏  
✓ Token存储在安全存储  
✓ 支持Token自动刷新  
✓ API请求自动包含Authorization头  

## 故障排查

### 问题：页面不显示
**解决**：确保在路由中正确注册了LoginScreen

### 问题：登录失败
**解决**：检查后端API是否已更新为支持密码字段

### 问题：注册后没有切换到登录页
**解决**：检查TabController是否正确初始化

### 问题：社交登录不工作
**解决**：确保已在原生代码中集成微信SDK和支付宝SDK

## 性能优化

- 使用SingleChildScrollView处理键盘遮挡
- TextEditingController正确dispose
- 避免不必要的重建
- 使用mounted检查防止内存泄漏

