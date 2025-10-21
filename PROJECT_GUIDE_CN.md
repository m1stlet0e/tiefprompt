# TiefPrompt 项目代码详解

## 📚 目录
1. [整体架构](#整体架构)
2. [启动流程](#启动流程)
3. [状态管理 (Riverpod)](#状态管理)
4. [数据层](#数据层)
5. [UI层](#ui层)
6. [核心功能](#核心功能)

---

## 整体架构

### 架构设计模式

这个项目使用了 **MVVM + Provider 模式**：

```
┌─────────────────────────────────────────────────────────┐
│                       UI Layer                          │
│  (Screens & Widgets - 用户界面)                        │
│  home_screen.dart, prompter_screen.dart...              │
└────────────────┬────────────────────────────────────────┘
                 │ 监听状态变化
                 ↓
┌─────────────────────────────────────────────────────────┐
│                  State Management                       │
│  (Riverpod Providers - 状态管理)                        │
│  prompter_provider, script_provider, settings_provider  │
└────────────────┬────────────────────────────────────────┘
                 │ 调用服务
                 ↓
┌─────────────────────────────────────────────────────────┐
│                   Service Layer                         │
│  (Business Logic - 业务逻辑)                           │
│  script_service.dart                                    │
└────────────────┬────────────────────────────────────────┘
                 │ 操作数据
                 ↓
┌─────────────────────────────────────────────────────────┐
│                    Data Layer                           │
│  (Database & Models - 数据存储)                        │
│  database.dart, script_model.dart                       │
└─────────────────────────────────────────────────────────┘
```

---

## 启动流程

### 1. 入口点文件

项目有**3个入口点**，根据不同的版本选择：

```dart
// main.dart - 开发时使用（未验证构建）
// main_foss.dart - 开源免费版
// main_freemium.dart - 免费增值版（App Store/Google Play）
```

**启动过程（以 main.dart 为例）**：

```dart
void main() async {
  // 1. 初始化 Flutter 绑定
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. 设置系统UI样式（透明导航栏、状态栏）
  SystemChrome.setSystemUIOverlayStyle(...)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  // 3. 初始化国际化
  await el.EasyLocalization.ensureInitialized();
  
  // 4. 运行应用
  runApp(
    ProviderScope(  // Riverpod 的根容器
      overrides: [
        // 这里可以覆盖特定的 Provider（用于测试或不同版本）
        featuresProvider.overrideWith(() => FeaturesUnverified())
      ],
      child: el.EasyLocalization(  // 国际化包装器
        supportedLocales: [Locale('en', 'US'), Locale('zh', 'CN'), ...],
        path: 'assets/translations',
        child: TeleprompterApp(),  // 应用主组件
      ),
    ),
  );
}
```

### 2. TeleprompterApp 初始化

```dart
class TeleprompterApp extends ConsumerStatefulWidget {
  @override
  void initState() {
    // 在第一帧渲染后执行
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 启动功能特性系统（检查是免费版还是专业版）
      final res = await ref.read(featuresProvider.notifier).bootstrap();
      
      if (!res) {
        // 如果启动失败，重置功能提供者
        ref.invalidate(featuresProvider);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 监听主题模式
    final themeMode = ref.watch(settingsProvider.select((s) => s.themeMode));
    
    // 监听路由
    final router = ref.watch(tiefPromptRouterProvider);
    
    // 监听亮色主题和暗色主题
    final lightTheme = ref.watch(themesProvider.select(...));
    final darkTheme = ref.watch(themesProvider.select(...));
    
    // 返回 MaterialApp
    return MaterialApp.router(
      title: 'Teleprompter',
      routerConfig: router,  // 使用 GoRouter
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
    );
  }
}
```

---

## 状态管理

### Riverpod 核心概念

这个项目使用 **Riverpod 2.x** 的代码生成方式。让我逐个解释核心 Provider：

### 1. ScriptProvider - 稿件状态管理

**作用**：管理用户输入的提词稿内容

```dart
// script_provider.dart

// State 定义 - 使用 Freezed 生成不可变数据类
@freezed
abstract class ScriptState with _$ScriptState {
  factory ScriptState({
    required String text,      // 稿件文本
    required String? title,    // 稿件标题（可选）
  }) = _ScriptState;
}

// Provider 定义 - 使用 riverpod_annotation 代码生成
@riverpod
class Script extends _$Script {
  @override
  ScriptState build() => ScriptState(text: "", title: null);  // 初始状态
  
  // 设置稿件文本
  void setText(String text) {
    state = state.copyWith(text: text);  // copyWith 是 Freezed 生成的方法
  }
  
  // 设置稿件标题
  void setTitle(String title) {
    state = state.copyWith(title: title);
  }
}

// 使用方式：
// 在 Widget 中：
final script = ref.watch(scriptProvider);           // 监听整个状态
final scriptText = ref.watch(scriptProvider).text;  // 只监听 text

// 修改状态：
ref.read(scriptProvider.notifier).setText("新的稿件内容");
```

**关键点**：
- `@freezed` 生成不可变数据类和 `copyWith` 方法
- `@riverpod` 生成 Provider 代码
- `state` 是当前状态，通过 `copyWith` 更新

---

### 2. PrompterProvider - 提词器运行时状态

**作用**：管理提词器的实时状态（播放速度、字体大小等）

```dart
// prompter_provider.dart

@freezed
abstract class PrompterState with _$PrompterState {
  factory PrompterState({
    @Default(1.0) double speed,              // 滚动速度
    @Default(false) bool mirroredX,          // X轴镜像
    @Default(false) bool mirroredY,          // Y轴镜像
    @Default(48.0) double fontSize,          // 字体大小
    @Default(false) bool isPlaying,          // 是否正在播放
    @Default(0.0) double sideMargin,         // 侧边距
    @Default('Roboto') String fontFamily,    // 字体
    @Default(TextAlign.left) TextAlign alignment,  // 对齐方式
    // ... 更多属性
  }) = _PrompterState;
}

@riverpod
class Prompter extends _$Prompter {
  Timer? _playPauseTimer;  // 倒计时定时器
  
  @override
  PrompterState build() {
    return PrompterState();  // 返回默认状态
  }
  
  // 调整速度
  void increaseSpeed(double amount) {
    if (state.speed + amount > kPrompterMaxSpeed) return;
    state = state.copyWith(speed: state.speed + amount);
  }
  
  void decreaseSpeed(double amount) {
    if (state.speed - amount < kPrompterMinSpeed) return;
    state = state.copyWith(speed: state.speed - amount);
  }
  
  // 播放/暂停切换
  void togglePlayPause() {
    if (state.isPlaying || _playPauseTimer != null) {
      // 如果正在播放，停止并取消倒计时
      _playPauseTimer?.cancel();
      _playPauseTimer = null;
      state = state.copyWith(displayCountdown: false, isPlaying: false);
    } else {
      // 如果已暂停，开始倒计时
      state = state.copyWith(displayCountdown: true);
      _playPauseTimer = Timer(
        Duration(seconds: state.countdownDuration.toInt()),
        () {
          // 倒计时结束后开始播放
          state = state.copyWith(isPlaying: true, displayCountdown: false);
          _playPauseTimer = null;
        },
      );
    }
  }
  
  // 从设置应用配置
  void applySettings(SettingsState settings) {
    state = state.copyWith(
      speed: settings.scrollSpeed,
      mirroredX: settings.mirroredX,
      fontSize: settings.fontSize,
      // ... 应用所有设置
    );
  }
}
```

**关键功能**：
- **实时状态管理**：不保存到本地，只在运行时存在
- **倒计时系统**：使用 Timer 实现播放前的倒计时
- **边界检查**：速度和字体大小有最大最小值限制

---

### 3. SettingsProvider - 用户设置持久化

**作用**：管理用户的偏好设置，保存到本地

```dart
// settings_provider.dart

@freezed
abstract class SettingsState with _$SettingsState {
  factory SettingsState({
    @Default(1.0) double scrollSpeed,
    @Default(false) bool mirroredX,
    @Default(42.0) double fontSize,
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(Color(0xFF4D67D6)) Color appPrimaryColor,
    // ... 更多设置
  }) = _SettingsState;
}

@Riverpod(keepAlive: true)  // keepAlive: true 表示不会自动销毁
class Settings extends _$Settings implements ISettings {
  // SharedPreferences 的键名
  static const _speedKey = 'scroll_speed';
  static const _fontSizeKey = 'font_size';
  // ...
  
  late final SharedPreferences _prefs;
  
  @override
  Future<SettingsState> build() async {
    // 初始化时从本地加载设置
    _prefs = await SharedPreferences.getInstance();
    
    return SettingsState().copyWith(
      scrollSpeed: _prefs.getDouble(_speedKey) ?? 1.0,
      fontSize: _prefs.getDouble(_fontSizeKey) ?? 42.0,
      // ... 加载所有设置
    );
  }
  
  // 保存滚动速度
  Future<void> setScrollSpeed(double speed) async {
    await _prefs.setDouble(_speedKey, speed);  // 保存到本地
    state = state.whenData((s) => s.copyWith(scrollSpeed: speed));  // 更新状态
  }
  
  // 重置所有设置
  Future<bool> resetSettings() async {
    state = AsyncData(SettingsState());  // 重置为默认状态
    return await _prefs.clear();  // 清空本地存储
  }
  
  // 从提词器状态应用设置（保存当前提词器的配置）
  Future<void> applySettingsFromPrompter(PrompterState prompterState) async {
    await setScrollSpeed(prompterState.speed);
    await setFontSize(prompterState.fontSize);
    // ... 保存所有属性
  }
}
```

**关键点**：
- 使用 `SharedPreferences` 持久化存储
- `AsyncValue<SettingsState>` 类型，因为加载是异步的
- `keepAlive: true` 保持 Provider 常驻内存
- 每次修改都**同时更新内存和本地存储**

---

### Provider 之间的关系

```
┌──────────────────┐
│ SettingsProvider │  ← 从本地加载用户设置
└────────┬─────────┘
         │
         │ applySettings()
         ↓
┌──────────────────┐
│ PrompterProvider │  ← 提词器运行时状态
└────────┬─────────┘
         │
         │ 使用
         ↓
┌──────────────────┐
│  ScriptProvider  │  ← 当前稿件内容
└────────┬─────────┘
         │
         │ save()
         ↓
┌──────────────────┐
│  ScriptService   │  ← 保存到数据库
└──────────────────┘
```

**数据流示例**：

1. **应用启动**：
   ```
   SettingsProvider 从 SharedPreferences 加载设置
   → 用户看到之前保存的主题、字体等配置
   ```

2. **用户输入稿件**：
   ```
   HomeScreen 输入框 onChange
   → scriptProvider.notifier.setText("内容")
   → ScriptProvider 更新 state
   → UI 自动重建显示新内容
   ```

3. **启动提词器**：
   ```
   用户点击"我要读稿了"按钮
   → prompterProvider.notifier.applySettings(settings)
   → PrompterProvider 从 Settings 加载默认配置
   → 导航到 PrompterScreen
   ```

4. **调整提词器**：
   ```
   用户按 + 键
   → prompterProvider.notifier.increaseSpeed(0.1)
   → PrompterProvider 更新 speed
   → ScrollableText 组件自动加快滚动
   ```

5. **保存设置**：
   ```
   用户按 Ctrl+S
   → settingsProvider.notifier.applySettingsFromPrompter(prompter)
   → Settings 将当前提词器状态保存到 SharedPreferences
   → 下次启动会使用这些设置
   ```

---

## 数据层

### 数据库架构 (Drift)

Drift 是 Flutter 中类型安全的 SQLite ORM。

#### 1. 数据模型定义

```dart
// script_model.dart

import 'package:drift/drift.dart';

// 使用 Drift 的表定义语法
class ScriptModel extends Table {
  // 主键，自动递增
  IntColumn get id => integer().autoIncrement()();
  
  // 稿件标题
  TextColumn get title => text()();
  
  // 稿件正文
  TextColumn get scriptText => text()();
  
  // 创建时间
  DateTimeColumn get createdAt => dateTime()();
}
```

**Drift 会自动生成**：
- `ScriptModelData` 类（数据实体）
- `ScriptModelCompanion` 类（用于插入/更新）
- 各种查询方法

#### 2. 数据库实例

```dart
// database.dart

@DriftDatabase(tables: [ScriptModel])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => 1;  // 数据库版本号
  
  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'tiefprompt',  // 数据库名称
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,  // 存储路径
      ),
    );
  }
}
```

#### 3. 服务层封装

```dart
// script_service.dart

@riverpod
class ScriptService extends _$ScriptService {
  final _databaseManagers = AppDatabase().managers;
  
  // 获取稿件总数
  Future<int> getScriptCount() async =>
      await _databaseManagers.scriptModel.count();
  
  // 获取所有稿件（返回 Stream，会自动更新）
  Future<Stream<List<ScriptDisplayData>>> getScripts() async =>
      _databaseManagers.scriptModel
        .asyncMap(_mapToDisplay)  // 映射为显示用的数据
        .watch();  // watch() 会监听数据库变化
  
  // 加载特定稿件
  Future<String> loadScript(int scriptId) async =>
      await _databaseManagers.scriptModel
        .filter((s) => s.id(scriptId))  // WHERE id = scriptId
        .asyncMap(_mapToText)
        .getSingle();  // 获取单条记录
  
  // 保存稿件
  Future<void> save(ScriptState script) async =>
      await _databaseManagers.scriptModel.create(
        (s) => s(
          scriptText: script.text,
          title: script.title ?? "Untitled",
          createdAt: DateTime.now(),
        ),
      );
  
  // 删除稿件
  Future<void> deleteScript(int scriptId) async =>
      await _databaseManagers.scriptModel
        .filter((s) => s.id(scriptId))
        .delete();
}
```

**使用示例**：

```dart
// 在 Widget 中使用
class OpenFileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取稿件服务
    final scriptService = ref.watch(scriptServiceProvider);
    
    return FutureBuilder<Stream<List<ScriptDisplayData>>>(
      future: scriptService.getScripts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        
        return StreamBuilder<List<ScriptDisplayData>>(
          stream: snapshot.data,
          builder: (context, scriptsSnapshot) {
            final scripts = scriptsSnapshot.data ?? [];
            
            return ListView.builder(
              itemCount: scripts.length,
              itemBuilder: (context, index) {
                final script = scripts[index];
                return ListTile(
                  title: Text(script.title),
                  subtitle: Text(script.createdAt.toString()),
                  onTap: () async {
                    // 加载稿件
                    final text = await scriptService.loadScript(script.id);
                    ref.read(scriptProvider.notifier).setText(text);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
```

---

## UI层

### 核心 Widget 组件

#### 1. ScrollableText - 自动滚动文本

这是提词器的核心组件，实现自动滚动效果。

```dart
// scrollable_text.dart

class ScrollableTextController {
  final ScrollController scrollController = ScrollController();
  
  // 跳转到指定位置
  void jumpTo(double offset) {
    if (scrollController.hasClients) {
      scrollController.jumpTo(offset);
    }
  }
  
  // 相对跳转
  void jumpRelative(double offset) {
    if (scrollController.hasClients) {
      scrollController.jumpTo(
        scrollController.offset + offset
      );
    }
  }
}

class ScrollableText extends ConsumerStatefulWidget {
  final ScrollableTextController controller;
  final String text;
  final TextStyle? style;
  final double sideMargin;
  
  @override
  _ScrollableTextState createState() => _ScrollableTextState();
}

class _ScrollableTextState extends ConsumerState<ScrollableText> {
  Timer? _scrollTimer;
  
  @override
  void initState() {
    super.initState();
    
    // 每帧检查是否需要滚动
    _scrollTimer = Timer.periodic(Duration(milliseconds: 16), (_) {
      final prompter = ref.read(prompterProvider);
      
      if (prompter.isPlaying && widget.controller.scrollController.hasClients) {
        // 计算滚动距离：速度 * 时间间隔
        final scrollDelta = prompter.speed * 16 / 1000;
        
        final newOffset = widget.controller.scrollController.offset + scrollDelta;
        final maxOffset = widget.controller.scrollController.position.maxScrollExtent;
        
        if (newOffset < maxOffset) {
          widget.controller.scrollController.jumpTo(newOffset);
        }
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final prompter = ref.watch(prompterProvider);
    
    return Transform(
      // 应用镜像变换
      transform: Matrix4.identity()
        ..scale(
          prompter.mirroredX ? -1.0 : 1.0,  // X轴镜像
          prompter.mirroredY ? -1.0 : 1.0,  // Y轴镜像
        ),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        controller: widget.controller.scrollController,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.sideMargin),
          child: Text(
            widget.text,
            style: widget.style,
            textAlign: prompter.alignment,
          ),
        ),
      ),
    );
  }
}
```

**工作原理**：
1. 每 16ms（约60fps）检查一次
2. 如果正在播放，根据速度计算移动距离
3. 使用 `jumpTo` 更新滚动位置
4. 使用 `Transform` 实现镜像效果

---

#### 2. PrompterScreen - 提词器主界面

```dart
class PrompterScreen extends ConsumerStatefulWidget {
  @override
  _PrompterScreenState createState() => _PrompterScreenState();
}

class _PrompterScreenState extends ConsumerState<PrompterScreen> {
  final _focusNode = FocusNode();
  late final ScrollableTextController _scrollableTextController;
  
  @override
  void initState() {
    super.initState();
    _scrollableTextController = ScrollableTextController();
    
    // 启用屏幕常亮
    WakelockPlus.enable();
    
    // 初始化滚动位置（滚动到屏幕中间）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollableTextController.jumpTo(
        MediaQuery.of(context).size.height / 2
      );
    });
    
    // 应用设置到提词器
    ref.read(settingsProvider).whenData((settings) {
      ref.read(prompterProvider.notifier).applySettings(settings);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final script = ref.watch(scriptProvider);
    final prompter = ref.watch(prompterProvider);
    final controlsVisible = ref.watch(controlsVisibleProvider);
    
    // 强制横屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    // 沉浸式模式
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (keyEvent) {
        if (keyEvent is KeyDownEvent) {
          _handleKeyPress(keyEvent);
        }
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 主文本区域
            GestureDetector(
              onTap: () {
                // 点击切换控制条显示
                ref.read(controlsVisibleProvider.notifier).state = 
                  !controlsVisible;
              },
              child: ScrollableText(
                controller: _scrollableTextController,
                text: script.text,
                style: TextStyle(
                  fontSize: prompter.fontSize,
                  fontFamily: prompter.fontFamily,
                ),
                sideMargin: MediaQuery.of(context).size.width / 2 * 
                  (prompter.sideMargin / 100),
              ),
            ),
            
            // 文字遮罩（上下渐变）
            if (prompter.displayVerticalMarginBoxes)
              VerticalMargin(
                heightRatio: prompter.verticalMarginBoxesHeight,
                fade: prompter.verticalMarginBoxesFadeEnabled,
                fadeLength: prompter.verticalMarginBoxesFadeLength / 100,
              ),
            
            // 助读区（高亮中间区域）
            if (prompter.displayReadingIndicatorBoxes)
              VerticalMargin(
                heightRatio: prompter.readingIndicatorBoxesHeight,
                color: Colors.white.withAlpha(60),
              ),
            
            // 顶部控制栏
            if (controlsVisible) PrompterTopBar(),
            
            // 底部控制栏
            if (controlsVisible) PrompterBottomBar(),
            
            // 倒计时
            if (prompter.displayCountdown && prompter.countdownDuration > 0)
              CountdownTimer(duration: prompter.countdownDuration.toInt()),
          ],
        ),
      ),
    );
  }
  
  void _handleKeyPress(KeyDownEvent keyEvent) {
    switch (keyEvent.logicalKey) {
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.space:
        // 空格/回车：播放/暂停
        ref.read(prompterProvider.notifier).togglePlayPause();
        break;
      
      case LogicalKeyboardKey.arrowUp:
        // 上箭头：向上滚动
        _scrollableTextController.jumpRelative(-75);
        break;
        
      // ... 更多快捷键
    }
    
    // 物理按键处理（+ / -）
    switch (keyEvent.physicalKey) {
      case PhysicalKeyboardKey.equal:  // + 键
        if (HardwareKeyboard.instance.isControlPressed) {
          ref.read(prompterProvider.notifier).increaseFontSize(1);
        } else {
          ref.read(prompterProvider.notifier).increaseSpeed(0.1);
        }
        break;
    }
  }
  
  @override
  void dispose() {
    // 恢复屏幕方向
    SystemChrome.setPreferredOrientations([]);
    
    // 恢复系统UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    
    // 禁用屏幕常亮
    WakelockPlus.disable();
    
    _focusNode.dispose();
    _scrollableTextController.dispose();
    super.dispose();
  }
}
```

**关键特性**：
- **键盘监听**：实现丰富的快捷键功能
- **屏幕常亮**：播放时防止屏幕休眠
- **横屏强制**：提词器必须横屏使用
- **沉浸式模式**：隐藏系统UI
- **层叠布局**：文本 + 遮罩 + 控制条多层堆叠

---

## 核心功能

### 1. 功能特性系统 (Fossium)

这是区分免费版和专业版功能的核心系统。

```dart
// core/constants.dart

// 所有可能的功能特性
enum Feature {
  appLanguage,           // 应用语言
  appTheme,             // 应用主题
  primaryAppColor,      // 主题色
  scrollSpeed,          // 滚动速度
  flipX,                // X轴镜像
  flipY,                // Y轴镜像
  readingIndicatorBoxes, // 助读区
  verticalMargins,      // 文字遮罩
  verticalMarginFade,   // 遮罩渐变
  sideMargins,          // 侧边距
  countdownTimer,       // 倒计时
  prompterBackgroundColor, // 提词器背景色
  prompterTextColor,    // 提词器文本色
  fontSize,             // 字体大小
  textAlignment,        // 文本对齐
  fontFamily,           // 字体
}

// 版本类型
enum FeatureKind {
  unverifiedBuild,  // 未验证构建（开发版）
  freeVersion,      // 免费版
  paidVersion,      // 专业版
  fossVersion       // 开源版（所有功能）
}

// 免费功能列表
const kFreeFeatures = [
  Feature.appLanguage,
  Feature.appTheme,
  Feature.scrollSpeed,
  Feature.flipX,
  Feature.flipY,
  Feature.readingIndicatorBoxes,
  Feature.sideMargins,
  Feature.fontSize,
  Feature.textAlignment,
];

// 所有功能（专业版和开源版）
const kAllFeatures = [
  ...kFreeFeatures,
  Feature.primaryAppColor,
  Feature.verticalMargins,
  Feature.verticalMarginFade,
  Feature.countdownTimer,
  Feature.prompterBackgroundColor,
  Feature.prompterTextColor,
  Feature.fontFamily,
];
```

**功能检查**：

```dart
// feature_provider.dart

@riverpod
class Features extends _$Features {
  @override
  AppFeatures build() {
    return AppFeatures(
      featureKind: FeatureKind.unverifiedBuild,  // 默认未验证
      availableFeatures: kFreeFeatures,  // 默认免费功能
    );
  }
  
  // 启动时初始化
  Future<bool> bootstrap() async {
    // 检查是否有专业版购买记录
    final hasPro = await _checkInAppPurchase();
    
    if (hasPro) {
      state = state.copyWith(
        featureKind: FeatureKind.paidVersion,
        availableFeatures: kAllFeatures,
      );
    } else {
      state = state.copyWith(
        featureKind: FeatureKind.freeVersion,
        availableFeatures: kFreeFeatures,
      );
    }
    
    return true;
  }
  
  // 购买专业版
  Future<void> buyPro() async {
    // 调用应用内购买
    final success = await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: proProduct),
    );
    
    if (success) {
      state = state.copyWith(
        featureKind: FeatureKind.paidVersion,
        availableFeatures: kAllFeatures,
      );
    }
  }
  
  // 检查功能是否可用
  bool isFeatureAvailable(Feature feature) {
    return state.availableFeatures.contains(feature);
  }
}
```

**使用方式**：

```dart
// 在设置界面中检查功能权限
class ColorPickerSetting extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final features = ref.watch(featuresProvider);
    
    // 检查主题色功能是否可用
    final isAvailable = features.availableFeatures.contains(
      Feature.primaryAppColor
    );
    
    return ListTile(
      title: Text('主题色'),
      trailing: isAvailable
        ? ColorPicker(...)  // 可用，显示颜色选择器
        : IconButton(
            icon: Icon(Icons.lock),  // 不可用，显示锁图标
            onPressed: () {
              // 提示用户购买专业版
              showDialog(...);
            },
          ),
    );
  }
}
```

---

### 2. 国际化系统

使用 `easy_localization` 包实现多语言。

**翻译文件结构**：

```
assets/translations/
  ├── en-US.json  # 英语
  ├── zh-CN.json  # 简体中文
  ├── de-DE.json  # 德语
  └── en@pirate.json  # 海盗英语（彩蛋）
```

**使用方法**：

```dart
// 在代码中使用
Text(context.tr("title"))  // 获取翻译

// 带参数的翻译
Text(context.tr("PrompterScreen.speed", args: [speed.toString()]))

// zh-CN.json 示例
{
  "title": "TiefPrompt 提词器",
  "HomeScreen": {
    "TextField_hintText": "输入需要提词的稿子",
    "ElevatedButton_Start": "我要读稿了"
  },
  "PrompterScreen": {
    "speed": "{} 倍速"
  }
}
```

---

## 总结

### 项目的优秀设计

1. **清晰的分层架构**：UI → State → Service → Data
2. **类型安全**：Freezed + Drift + Riverpod 代码生成
3. **响应式设计**：状态变化自动更新 UI
4. **持久化管理**：SharedPreferences + SQLite
5. **功能权限系统**：灵活的免费/付费功能控制
6. **国际化支持**：方便添加新语言

### 技术栈总结

- **状态管理**: Riverpod 2.x (代码生成)
- **数据类**: Freezed (不可变 + copyWith)
- **数据库**: Drift (类型安全的 SQLite ORM)
- **路由**: GoRouter
- **国际化**: EasyLocalization
- **本地存储**: SharedPreferences
- **应用内购买**: in_app_purchase

### 下一步学习建议

1. 运行代码生成：`flutter pub run build_runner build`
2. 尝试修改一个简单功能（如默认字体大小）
3. 添加一个新的设置项
4. 理解 Riverpod 的依赖注入机制
5. 学习 Drift 的查询语法

---

有任何疑问随时问我！

