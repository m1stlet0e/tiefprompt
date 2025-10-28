# Promptify 深度代码解析

## 📖 核心组件深度剖析

---

## 1. ScrollableText - 自动滚动的核心实现

这是提词器最关键的组件，实现了平滑的自动滚动效果。

### 完整代码解析

```dart
class _ScrollableTextState extends ConsumerState<ScrollableText>
    with SingleTickerProviderStateMixin {  // 混入 Ticker 支持
  
  Ticker? _ticker;      // 帧率控制器
  double _scrollSpeed = 0;  // 当前滚动速度
  Function? _onReachedEnd;  // 到达末尾的回调
```

**关键概念：Ticker**

`Ticker` 是 Flutter 的帧率同步机制，每次屏幕刷新（通常60fps）都会触发一次。

```dart
  @override
  void initState() {
    super.initState();
    
    // 创建 Ticker，每帧都会调用 _tick()
    _ticker = createTicker((Duration elapsed) {
      _tick();  // 每帧执行一次
    });
  }
```

### 核心滚动逻辑

```dart
  void _tick() {
    // 1. 检查用户是否正在手动滚动
    final isUserScrolling = ref.watch(_userScrollingProvider);
    
    // 2. 计算每帧应该滚动的距离
    // 公式：速度 * 字体大小 / 10
    // 字体越大，相同速度下滚动越快（保持视觉一致性）
    final calculatedScrollOffset =
        (_scrollSpeed * (widget.style?.fontSize ?? 48)) / 10;
    
    // 3. 只在满足条件时滚动
    if (widget.controller.scrollController.hasClients  // 控制器已连接
        && !isUserScrolling) {  // 用户没有手动滚动
      
      // 4. 检查是否到达末尾
      if (widget.controller.scrollController.position.pixels +
              calculatedScrollOffset >=
          widget.controller.scrollController.position.maxScrollExtent) {
        _onReachedEnd?.call();  // 调用结束回调（自动暂停）
        return;
      }
      
      // 5. 执行滚动动画
      widget.controller.scrollController.animateTo(
        widget.controller.scrollController.position.pixels +
            calculatedScrollOffset,  // 目标位置
        duration: Duration(milliseconds: 100),  // 动画时长
        curve: Curves.linear,  // 线性插值（匀速）
      );
    }
  }
```

### 为什么使用 Ticker 而不是 Timer?

```dart
// ❌ 不好的做法（使用 Timer）
Timer.periodic(Duration(milliseconds: 16), (_) {
  // 可能与屏幕刷新不同步，造成卡顿
});

// ✅ 好的做法（使用 Ticker）
_ticker = createTicker((elapsed) {
  // 与屏幕刷新完全同步，流畅度最佳
});
```

### UI 构建

```dart
  @override
  Widget build(BuildContext context) {
    final mediaHeight = MediaQuery.of(context).size.height;
    final prompter = ref.watch(prompterProvider);
    
    // 监听用户手动滚动
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.controller.scrollController.position.isScrollingNotifier
          .addListener(() {
        // 用户手动滚动时，设置标志位
        ref.read(_userScrollingProvider.notifier).state = widget
            .controller.scrollController.position.isScrollingNotifier.value;
      });
    });
    
    // 到达末尾时自动暂停
    _onReachedEnd = () {
      ref.read(prompterProvider.notifier).togglePlayPause();
    };
    
    // 根据播放状态启动/停止滚动
    if (prompter.isPlaying) {
      _startScrolling(prompter.speed);
    } else {
      _stopScrolling();
    }
    
    return Transform.flip(
      flipX: prompter.mirroredX,  // X轴镜像
      flipY: prompter.mirroredY,  // Y轴镜像
      child: SingleChildScrollView(
        controller: widget.controller.scrollController,
        padding: EdgeInsets.fromLTRB(
          widget.sideMargin,   // 左边距
          mediaHeight,         // 上padding（初始滚动位置）
          widget.sideMargin,   // 右边距
          0                    // 下padding
        ),
        child: Column(
          children: [
            // 主文本
            Text(
              widget.text,
              style: widget.style,
              textAlign: prompter.alignment,
            ),
            // 结束提示（占满屏幕高度）
            SizedBox(
              height: mediaHeight,
              child: Center(
                child: Text("The End", style: widget.style)
              ),
            ),
          ],
        ),
      ),
    );
  }
```

### 滚动速度计算详解

```
假设：
- 速度设置为 1.0
- 字体大小为 48
- 屏幕刷新率 60fps (每帧约16.67ms)

每帧滚动距离 = (1.0 * 48) / 10 = 4.8 像素
每秒滚动距离 = 4.8 * 60 = 288 像素

如果字体大小改为 96（2倍）：
每帧滚动距离 = (1.0 * 96) / 10 = 9.6 像素
每秒滚动距离 = 9.6 * 60 = 576 像素（正好也是2倍）

结论：字体大小翻倍，滚动距离也翻倍，视觉速度保持一致
```

---

## 2. 路由系统 (GoRouter)

### 路由配置

```dart
@Riverpod(keepAlive: true, dependencies: [Themes])
class PromptifyRouter extends _$PromptifyRouter {
  @override
  GoRouter build() {
    return GoRouter(
      initialLocation: '/',  // 初始路由
      routes: [
        // 主页
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const BannerListener(child: HomeScreen()),
        ),
        
        // 提词器页面
        GoRoute(
          path: '/teleprompter',
          builder: (context, state) {
            // 读取提词器专用主题
            final theme = ref
                .read(themesProvider)
                .whenOrNull(data: (d) => d.prompterTheme);
            
            return BannerListener(
              child: Theme(
                data: theme ?? ThemeData.dark(),  // 提词器使用独立主题
                child: const PrompterScreen(),
              ),
            );
          },
        ),
        
        // 文件选择页面
        GoRoute(
          path: '/open_file',
          builder: (context, state) =>
              const BannerListener(child: OpenFileScreen()),
        ),
        
        // 设置页面（带嵌套路由）
        GoRoute(
          path: '/settings',
          builder: (context, state) =>
              const BannerListener(child: SettingsScreen()),
          routes: [
            // /settings/display
            GoRoute(
              path: 'display',
              builder: (context, state) =>
                  const BannerListener(child: DisplaySettingsScreen()),
            ),
            // /settings/text
            GoRoute(
              path: 'text',
              builder: (context, state) =>
                  const BannerListener(child: TextSettingsScreen()),
            ),
          ],
        ),
      ],
    );
  }
}
```

### 路由导航

```dart
// 跳转到提词器
context.push('/teleprompter');

// 返回上一页
context.pop();

// 替换当前路由
context.replace('/home');

// 跳转到嵌套路由
context.push('/settings/display');
```

### BannerListener 包装器

所有页面都被 `BannerListener` 包装，用于显示应用内购买的横幅通知。

```dart
class BannerListener extends ConsumerWidget {
  final Widget child;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听横幅状态
    ref.listen(bannerProvider, (previous, next) {
      if (next.shouldShow) {
        // 显示购买横幅
        ScaffoldMessenger.of(context).showMaterialBanner(...);
      }
    });
    
    return child;
  }
}
```

---

## 3. 功能特性系统详解

### 架构设计

```
FeatureProvider (抽象基类)
    │
    ├── FeaturesUnverified  ← 开发版（所有功能，带警告）
    │
    ├── FeaturesFoss        ← 开源版（所有功能）
    │
    └── FeaturesFreemium    ← 免费增值版
            │
            ├── Free (默认)   ← 基础功能
            │
            └── Pro (购买后)  ← 所有功能
```

### 基类实现

```dart
// feature_provider.dart

@riverpod
class Features extends _$Features {
  @override
  AppFeatures build() {
    return AppFeatures(
      [],  // 空功能列表
      FeatureKind.unverifiedBuild,  // 未验证构建
    );
  }
  
  // 子类必须实现
  Future<bool> bootstrap() {
    throw UnimplementedError('bootstrap must be implemented in subclasses');
  }
  
  // 子类必须实现（免费增值版需要）
  Future<void> buyPro() {
    throw UnimplementedError('buyPro must be implemented in subclasses');
  }
}
```

### 开源版实现

```dart
// feature_provider_foss.dart

class FeaturesFoss extends Features {
  @override
  AppFeatures build() {
    return AppFeatures(
      kAllFeatures,           // 所有功能
      FeatureKind.fossVersion,  // 开源版标识
    );
  }
  
  @override
  Future<bool> bootstrap() async {
    // 开源版无需初始化，直接返回成功
    return true;
  }
  
  @override
  Future<void> buyPro() async {
    // 开源版无需购买，空实现
  }
}
```

### 免费增值版实现

```dart
// feature_provider_freemium.dart

class FeaturesFreemium extends Features {
  final InAppPurchase _iap = InAppPurchase.instance;
  
  @override
  AppFeatures build() {
    return AppFeatures(
      kFreeFeatures,           // 初始只有免费功能
      FeatureKind.freeVersion,  // 免费版标识
    );
  }
  
  @override
  Future<bool> bootstrap() async {
    // 1. 检查应用内购买是否可用
    if (!await _iap.isAvailable()) {
      return false;
    }
    
    // 2. 获取产品信息
    const Set<String> kIds = {kProId};  // 专业版产品ID
    final ProductDetailsResponse response = 
        await _iap.queryProductDetails(kIds);
    
    if (response.notFoundIDs.isNotEmpty) {
      return false;
    }
    
    // 3. 检查是否已购买专业版
    await _iap.restorePurchases();  // 恢复购买记录
    final purchases = await _iap.getPurchases();
    
    final hasPro = purchases.any((p) => 
      p.productID == kProId && p.status == PurchaseStatus.purchased
    );
    
    if (hasPro) {
      // 已购买，升级到专业版
      state = AppFeatures(
        kAllFeatures,
        FeatureKind.paidVersion,
      );
    }
    
    return true;
  }
  
  @override
  Future<void> buyPro() async {
    // 1. 获取产品详情
    final response = await _iap.queryProductDetails({kProId});
    if (response.productDetails.isEmpty) return;
    
    final productDetails = response.productDetails.first;
    
    // 2. 发起购买
    final purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );
    
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    
    // 3. 监听购买结果
    _iap.purchaseStream.listen((purchases) {
      for (var purchase in purchases) {
        if (purchase.productID == kProId) {
          if (purchase.status == PurchaseStatus.purchased) {
            // 购买成功，升级功能
            state = AppFeatures(
              kAllFeatures,
              FeatureKind.paidVersion,
            );
            
            // 完成购买流程
            _iap.completePurchase(purchase);
          }
        }
      }
    });
  }
}
```

### 在不同入口点使用

```dart
// main_foss.dart
runApp(
  ProviderScope(
    overrides: [
      // 覆盖为开源版
      featuresProvider.overrideWith(() => FeaturesFoss())
    ],
    child: TeleprompterApp(),
  ),
);

// main_freemium.dart
runApp(
  ProviderScope(
    overrides: [
      // 覆盖为免费增值版
      featuresProvider.overrideWith(() => FeaturesFreemium())
    ],
    child: TeleprompterApp(),
  ),
);

// main.dart (开发用)
runApp(
  ProviderScope(
    overrides: [
      // 覆盖为未验证版（开发时使用）
      featuresProvider.overrideWith(() => FeaturesUnverified())
    ],
    child: TeleprompterApp(),
  ),
);
```

### UI中检查功能

```dart
class PremiumFeatureWidget extends ConsumerWidget {
  final Feature requiredFeature;
  final Widget child;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final features = ref.watch(featuresProvider);
    
    // 检查功能是否可用
    final isAvailable = features.availableFeatures.contains(requiredFeature);
    
    if (isAvailable) {
      return child;  // 功能可用，正常显示
    } else {
      // 功能不可用，显示锁定状态
      return Stack(
        children: [
          Opacity(opacity: 0.3, child: child),  // 半透明显示
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, size: 48),
                Text(
                  context.tr(kFeatureDescriptions[requiredFeature]!),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 提示购买专业版
                    ref.read(featuresProvider.notifier).buyPro();
                  },
                  child: Text('升级到专业版'),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}

// 使用示例
PremiumFeatureWidget(
  requiredFeature: Feature.primaryAppColor,
  child: ColorPicker(
    onColorChanged: (color) {
      ref.read(settingsProvider.notifier).setAppPrimaryColor(color);
    },
  ),
)
```

---

## 4. 主题系统

### 主题提供者

```dart
// theme_provider.dart

@freezed
class ThemeState with _$ThemeState {
  factory ThemeState({
    required ThemeData lightTheme,   // 亮色主题
    required ThemeData darkTheme,    // 暗色主题
    required ThemeData prompterTheme, // 提词器专用主题
  }) = _ThemeState;
}

@riverpod
class Themes extends _$Themes {
  @override
  Future<ThemeState> build() async {
    // 等待设置加载完成
    final settings = await ref.watch(settingsProvider.future);
    
    // 创建主题
    return ThemeState(
      lightTheme: _buildLightTheme(settings.appPrimaryColor),
      darkTheme: _buildDarkTheme(settings.appPrimaryColor),
      prompterTheme: _buildPrompterTheme(
        settings.prompterBackgroundColor,
        settings.prompterTextColor,
      ),
    );
  }
  
  ThemeData _buildLightTheme(Color primaryColor) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
    );
  }
  
  ThemeData _buildDarkTheme(Color primaryColor) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
    );
  }
  
  ThemeData _buildPrompterTheme(Color bgColor, Color textColor) {
    return ThemeData(
      scaffoldBackgroundColor: bgColor,  // 提词器背景色
      colorScheme: ColorScheme.fromSeed(
        seedColor: textColor,
        brightness: bgColor.computeLuminance() > 0.5 
          ? Brightness.light 
          : Brightness.dark,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textColor),  // 提词器文本色
      ),
    );
  }
}
```

### 主题如何应用

```dart
// teleprompter_app.dart

@override
Widget build(BuildContext context) {
  // 监听主题模式
  final themeMode = ref.watch(
    settingsProvider.select((s) => s.whenData((d) => d.themeMode))
  );
  
  // 监听亮色主题
  final lightTheme = ref.watch(
    themesProvider.select((t) => t.whenData((d) => d.lightTheme))
  );
  
  // 监听暗色主题
  final darkTheme = ref.watch(
    themesProvider.select((t) => t.whenData((d) => d.darkTheme))
  );
  
  // 合并所有异步状态
  final combiningProvider = ref.watch(
    combinedAsyncDataProvider([themeMode, lightTheme, darkTheme])
  );
  
  return switch (combiningProvider) {
    AsyncData(:final value) => MaterialApp.router(
      theme: value.states[1] as ThemeData,      // 亮色主题
      darkTheme: value.states[2] as ThemeData,  // 暗色主题
      themeMode: value.states[0] as ThemeMode,  // 主题模式
      routerConfig: router,
    ),
    AsyncLoading() => LoadingScreen(),
    _ => ErrorScreen(),
  };
}
```

---

## 5. 完整的用户操作流程

### 场景1: 用户首次启动应用

```
1. main() 函数执行
   ↓
2. ProviderScope 初始化
   - featuresProvider 被注入（根据编译版本）
   ↓
3. TeleprompterApp.initState()
   - featuresProvider.bootstrap() 执行
   - 免费增值版：检查是否购买过专业版
   - 开源版：直接启用所有功能
   ↓
4. settingsProvider 从 SharedPreferences 加载设置
   - 如果是首次启动，使用默认值
   ↓
5. themesProvider 根据设置构建主题
   ↓
6. MaterialApp 渲染完成
   ↓
7. 导航到 HomeScreen
```

### 场景2: 用户输入稿件并开始提词

```
用户在主页输入框输入文本
   ↓
TextField.onChanged 触发
   ↓
scriptProvider.notifier.setText("内容")
   ↓
ScriptProvider 更新 state
   ↓
TextField 自动重建（因为 controller.text 与 state 同步）
   
---

用户点击"我要读稿了"按钮
   ↓
ElevatedButton.onPressed 触发
   ↓
ref.invalidate(prompterProvider)  // 重置提词器状态
   ↓
context.push('/teleprompter')  // 导航到提词器
   ↓
PrompterScreen.initState()
   - 应用设置到提词器
   - 启用屏幕常亮
   - 强制横屏
   ↓
PrompterScreen 构建
   - ScrollableText 创建 Ticker
   - 初始滚动位置设置为屏幕中间
   ↓
用户看到提词器界面
```

### 场景3: 提词过程中的实时调整

```
用户按下空格键
   ↓
KeyboardListener.onKeyEvent 捕获
   ↓
prompterProvider.notifier.togglePlayPause()
   ↓
PrompterState 更新：
   - displayCountdown = true
   - 启动倒计时 Timer
   ↓
CountdownTimer Widget 显示倒计时
   ↓
倒计时结束，Timer 回调触发
   ↓
PrompterState 更新：
   - isPlaying = true
   - displayCountdown = false
   ↓
ScrollableText 监听到 isPlaying = true
   ↓
_startScrolling() 启动 Ticker
   ↓
每帧 (60fps)：
   _tick() 执行
   ↓ 计算滚动距离
   ↓ animateTo() 更新滚动位置
   ↓ UI 重绘
   
---

同时，用户按下 + 键
   ↓
KeyboardListener 捕获
   ↓
prompterProvider.notifier.increaseSpeed(0.1)
   ↓
PrompterState.speed 更新（1.0 → 1.1）
   ↓
下一帧 _tick() 使用新速度计算滚动距离
   ↓
滚动速度立即变快
```

### 场景4: 保存当前配置

```
用户按下 Ctrl+S
   ↓
KeyboardListener 捕获
   ↓
settingsProvider.notifier.applySettingsFromPrompter(prompter)
   ↓
SettingsProvider 执行一系列保存操作：
   - setScrollSpeed() → SharedPreferences
   - setFontSize() → SharedPreferences
   - setMirroredX() → SharedPreferences
   - ... (所有设置)
   ↓
每个设置保存后更新 state
   ↓
下次启动时会使用这些设置
```

---

## 6. 性能优化技巧

### Riverpod 的 select 优化

```dart
// ❌ 不好的做法（整个 settings 变化都会重建）
final settings = ref.watch(settingsProvider);
return Text('Speed: ${settings.scrollSpeed}');

// ✅ 好的做法（只有 scrollSpeed 变化才重建）
final speed = ref.watch(
  settingsProvider.select((s) => s.whenData((d) => d.scrollSpeed))
);
return Text('Speed: $speed');
```

### Freezed 的 copyWith 优化

```dart
// Freezed 生成的 copyWith 只会创建必要的新对象
state = state.copyWith(speed: 1.5);  // 只修改 speed，其他字段共享引用
```

### Provider 的 keepAlive

```dart
// 需要保持状态的 Provider 使用 keepAlive
@Riverpod(keepAlive: true)
class Settings extends _$Settings { ... }

// 临时状态的 Provider 不使用 keepAlive（自动清理）
@riverpod
class Prompter extends _$Prompter { ... }
```

---

这份文档涵盖了项目最核心的实现细节。如果你对某个部分还有疑问，随时问我！

