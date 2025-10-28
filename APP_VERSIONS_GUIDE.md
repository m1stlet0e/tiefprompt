# 应用版本指南 - 三种运行模式

## 快速启动

### 1. 开发版 (Unverified/Debug)
```bash
flutter run
# 或
flutter run -t lib/main.dart
```
**用途**: 日常开发、测试、调试  
**特点**: 所有功能免费、显示调试信息、未验证构建

### 2. 开源免费版 (FOSS)
```bash
flutter run -t lib/main_foss.dart
```
**用途**: 发布到开源市场、用户永久免费版  
**特点**: 所有功能永久解锁、无广告、无应用内购买

### 3. 付费增值版 (Freemium)
```bash
flutter run -t lib/main_freemium.dart
```
**用途**: 发布到应用商店 (App Store / Google Play)  
**特点**: 基础功能免费、高级功能付费、应用内购买

---

## 详细对比

### 功能差异

| 功能 | 开发版 | FOSS版 | Freemium版 |
|-----|-------|--------|-----------|
| 基础提词 | ✅ | ✅ | ✅ |
| 高级格式 | ✅ | ✅ | 🔒 需付费 |
| 滚动效果 | ✅ | ✅ | 🔒 需付费 |
| 显示模式 | ✅ | ✅ | ✅ |
| 快速模式 | ✅ | ✅ | ✅ |
| 应用内购买 | ❌ | ❌ | ✅ |
| 登录系统 | ✅ | ✅ | ✅ |
| 微信/支付宝登录 | ✅ | ✅ | ✅ |

### 代码实现位置

**共同代码**:
- `lib/main.dart` (开发版入口)
- `lib/main_freemium.dart` (Freemium 入口)
- `lib/main_foss.dart` (FOSS 入口)

**特性管理**:
- `lib/providers/feature_provider.dart` (基础)
- `lib/providers/feature_provider_unverified.dart` (开发版)
- `lib/providers/feature_provider_freemium.dart` (Freemium 版)
- `lib/providers/feature_provider_foss.dart` (FOSS 版)

**常量定义**:
- `lib/core/constants.dart`
  - `kFreeFeatures` - 免费功能列表
  - `kPremiumFeatures` - 高级功能列表
  - `kAllFeatures` - 所有功能列表

---

## Freemium 模式深入

### 商业模式

```
用户安装应用
    ↓
看到免费功能可用
    ↓
尝试使用高级功能
    ↓
提示: "升级到 Pro"
    ↓
点击升级 → PaymentScreen
    ↓
选择支付方式 (微信/支付宝)
    ↓
完成支付
    ↓
解锁所有功能
```

### 功能解锁流程

1. **应用启动**
   - `FeaturesFreemium()` 初始化
   - 检查用户是否购买专业版
   - 从 App Store/Play Store 验证购买

2. **动态功能可用性**
   ```dart
   if (user.isPaidUser) {
     // 显示所有高级功能
   } else {
     // 显示基础功能 + "升级" 按钮
   }
   ```

3. **支付流程**
   - 用户点击 "升级" 按钮
   - 导航到 `PaymentScreen`
   - 选择支付方式
   - 调用 `PaymentService`
   - 处理支付回调

### 与登录系统的整合

```
┌─────────────────────────────────────────────┐
│         Freemium 应用流程                    │
├─────────────────────────────────────────────┤
│                                              │
│  [启动] → [检查登录]                        │
│              ↓                              │
│          未登录 → [LoginScreen]             │
│          已登录 → [首页]                    │
│                    ↓                        │
│            [尝试用高级功能]                 │
│                    ↓                        │
│              [检查付费状态]                 │
│                    ↓                        │
│            未付费 → [显示升级]              │
│            已付费 → [使用功能]              │
│                    ↓                        │
│            [点击升级] → [PaymentScreen]    │
│                    ↓                        │
│            [支付成功] → [更新状态]          │
│                    ↓                        │
│            [解锁功能] → [回到首页]          │
│                                              │
└─────────────────────────────────────────────┘
```

---

## 关键文件对应

### 认证相关
- `lib/services/auth_service.dart` - 用户登录/注册
- `lib/ui/screens/login_screen.dart` - 登录界面
- `lib/providers/auth_provider.dart` - 认证状态

### 支付相关
- `lib/services/payment_service.dart` - 支付处理
- `lib/ui/screens/payment_screen.dart` - 支付界面
- `lib/providers/payment_provider.dart` - 支付状态
- `lib/models/payment_model.dart` - 支付数据模型

### 特性管理
- `lib/providers/feature_provider.dart` - 功能 Provider
- `lib/providers/feature_provider_freemium.dart` - Freemium 实现
- `lib/core/constants.dart` - 功能定义

---

## 构建命令

### 开发测试

```bash
# 开发版
flutter run

# FOSS 版
flutter run -t lib/main_foss.dart

# Freemium 版
flutter run -t lib/main_freemium.dart
```

### 生产构建

```bash
# iOS Release
flutter build ios -t lib/main_freemium.dart --release

# Android APK Release
flutter build apk -t lib/main_freemium.dart --release

# Android App Bundle (推荐用于 Play Store)
flutter build appbundle -t lib/main_freemium.dart --release
```

### 指定输出

```bash
# 指定输出目录
flutter build ios -t lib/main_freemium.dart --release \
  -o build/ios/release

# 生成 IPA 包
flutter build ios -t lib/main_freemium.dart --release
cd build/ios/release/Runner.xcarchive
xcodebuild -exportArchive -archivePath . \
  -exportPath . -exportOptionsPlist options.plist
```

---

## 版本控制建议

### Git 分支策略

```
main (生产)
  ├─ release/freemium (App Store/Play Store)
  ├─ release/foss (开源市场)
  └─ develop (开发)
      ├─ feature/auth (认证功能)
      ├─ feature/payment (支付功能)
      └─ bugfix/* (缺陷修复)
```

### 版本号管理

在 `pubspec.yaml` 中：

```yaml
version: 1.0.0+1
# 格式: major.minor.patch+buildNumber
# Freemium: 1.0.0+1
# FOSS: 1.0.0-foss+1
```

---

## 测试检查清单

### Freemium 版本测试

- [ ] 应用启动正常
- [ ] 未登录时显示登录提示
- [ ] 登录流程正常
- [ ] 登录后可访问基础功能
- [ ] 尝试高级功能时显示 "升级" 提示
- [ ] 点击 "升级" 进入支付屏幕
- [ ] 支付屏幕显示微信和支付宝选项
- [ ] 用户可以选择支付方式
- [ ] 支付完成后解锁高级功能
- [ ] 登出后重新登录，高级功能仍保持

### FOSS 版本测试

- [ ] 应用启动正常
- [ ] 所有功能都可用
- [ ] 没有 "升级" 提示
- [ ] 没有应用内购买选项
- [ ] 登录系统正常工作

### 开发版本测试

- [ ] 显示 "未验证构建" 或 DEBUG 标志
- [ ] 所有功能都可用
- [ ] 日志输出正常
- [ ] 调试工具可用

---

## 常见问题

### Q: 如何在开发中切换版本?

A: 使用不同的入口文件运行:
```bash
flutter run -t lib/main_freemium.dart
```

### Q: Freemium 版本如何验证购买?

A: 通过 `in_app_purchase` 包验证:
- iOS: 与 Apple App Store 通信
- Android: 与 Google Play 通信

### Q: 如何测试支付功能?

A: 在沙箱环境中:
- iOS: 使用 App Store Connect 的沙箱账户
- Android: 使用 Google Play Console 的测试账户

### Q: 打包时如何选择版本?

A: 在构建命令中指定:
```bash
flutter build ios -t lib/main_freemium.dart --release
```

---

## 发布流程

### 到 App Store

1. 使用 `lib/main_freemium.dart` 构建
2. 生成 IPA 包
3. 上传到 App Store Connect
4. 配置应用内购买产品 ID
5. 审核通过后发布

### 到 Google Play

1. 使用 `lib/main_freemium.dart` 构建
2. 生成 App Bundle
3. 上传到 Google Play Console
4. 配置应用内购买产品 ID
5. 审核通过后发布

### 到开源市场

1. 使用 `lib/main_foss.dart` 构建
2. 上传到 F-Droid 或其他开源市场
3. 无需配置应用内购买

---

## 提示和最佳实践

1. **始终在 Freemium 模式下测试商业逻辑**
   - 确保功能正确启用/禁用
   - 测试支付流程

2. **分开测试每个版本**
   - 开发版: 快速迭代
   - FOSS 版: 测试免费体验
   - Freemium 版: 完整测试

3. **使用特性标志进行 A/B 测试**
   - 在特定版本中启用/禁用功能
   - 收集用户反馈

4. **定期更新应用内购买产品**
   - 保持价格竞争力
   - 定期添加新功能

---

**最后更新**: 2024年10月28日  
**版本**: 1.0  
**状态**: ✅ 已完成
