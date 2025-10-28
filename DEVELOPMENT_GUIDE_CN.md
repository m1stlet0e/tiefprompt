# Promptify 开发指南

## 🚀 快速开始

### 环境要求

- Flutter SDK: 3.8.1+
- Dart SDK: 3.8.1+
- iOS开发: Xcode 14+, CocoaPods
- Android开发: Android Studio, SDK 21+

### 安装和运行

```bash
# 1. 克隆项目
git clone git@github.com:Tiefseetauchner/tiefprompt.git
cd tiefprompt

# 2. 安装依赖
flutter pub get

# 3. 运行代码生成（重要！）
flutter pub run build_runner build --delete-conflicting-outputs

# 4. 运行应用（开发版）
flutter run

# 5. 运行特定版本
flutter run -t lib/main_foss.dart       # 开源版
flutter run -t lib/main_freemium.dart   # 免费增值版
```

---

## 📁 项目结构速查

```
lib/
├── core/
│   └── constants.dart                 # 常量定义
│
├── models/                           # 数据模型
│   ├── database.dart                 # 数据库定义
│   ├── database.g.dart              # 生成的代码
│   └── script_model.dart            # 稿件表定义
│
├── providers/                        # 状态管理
│   ├── prompter_provider.dart       # 提词器状态
│   ├── script_provider.dart         # 稿件状态
│   ├── settings_provider.dart       # 设置状态
│   ├── feature_provider.dart        # 功能特性（基类）
│   ├── feature_provider_foss.dart   # 开源版实现
│   ├── feature_provider_freemium.dart # 免费增值版实现
│   ├── theme_provider.dart          # 主题管理
│   ├── router_provider.dart         # 路由配置
│   └── *.g.dart / *.freezed.dart   # 生成的代码
│
├── services/                         # 业务逻辑
│   └── script_service.dart          # 稿件服务
│
├── ui/
│   ├── screens/                     # 页面
│   │   ├── home_screen.dart         # 主页
│   │   ├── prompter_screen.dart     # 提词器页面
│   │   ├── settings_screen.dart     # 设置页面
│   │   └── open_file_screen.dart    # 文件选择页面
│   │
│   └── widgets/                     # 组件
│       ├── scrollable_text.dart     # 自动滚动文本
│       ├── countdown_timer.dart     # 倒计时
│       ├── prompter_top_bar.dart    # 顶部控制栏
│       ├── prompter_bottom_bar.dart # 底部控制栏
│       └── vertical_margin.dart     # 垂直边距
│
├── main.dart                         # 开发入口
├── main_foss.dart                   # 开源版入口
├── main_freemium.dart               # 免费增值版入口
└── teleprompter_app.dart            # 应用主组件
```

---

## 🔧 常用开发命令

### 代码生成

```bash
# 一次性生成（删除冲突文件）
flutter pub run build_runner build --delete-conflicting-outputs

# 监听模式（自动生成）
flutter pub run build_runner watch --delete-conflicting-outputs

# 清理生成的文件
flutter pub run build_runner clean
```

### 构建应用

```bash
# Android APK（开源版）
flutter build apk -t lib/main_foss.dart

# Android AAB（免费增值版）
flutter build appbundle -t lib/main_freemium.dart

# iOS
flutter build ios -t lib/main_foss.dart

# macOS
flutter build macos -t lib/main_foss.dart

# Windows
flutter build windows -t lib/main_foss.dart

# Linux
flutter build linux -t lib/main_foss.dart
```

### 使用构建脚本

```bash
# 构建所有平台（开源版）
./tools/build.sh -t linux,windows,androidapk -f foss

# 构建免费增值版
./tools/build.sh -t androidaab,iosipa -f freemium

# 调试构建
./tools/build.sh -t linux -f foss -d
```

---

## 💡 常见开发任务

### 1. 添加新的设置项

**步骤：**

```dart
// 1. 在 settings_provider.dart 的 SettingsState 中添加字段
@freezed
abstract class SettingsState with _$SettingsState {
  factory SettingsState({
    // ... 现有字段
    @Default(false) bool myNewSetting,  // 新增
  }) = _SettingsState;
}

// 2. 在 Settings 类中添加常量键
class Settings extends _$Settings {
  static const _myNewSettingKey = 'my_new_setting';
  
  // 3. 在 build() 中加载设置
  @override
  Future<SettingsState> build() async {
    _prefs = await SharedPreferences.getInstance();
    return SettingsState().copyWith(
      // ... 现有加载
      myNewSetting: _prefs.getBool(_myNewSettingKey) ?? false,
    );
  }
  
  // 4. 添加设置方法
  Future<void> setMyNewSetting(bool value) async {
    await _prefs.setBool(_myNewSettingKey, value);
    state = state.whenData((s) => s.copyWith(myNewSetting: value));
  }
}

// 5. 运行代码生成
// flutter pub run build_runner build --delete-conflicting-outputs

// 6. 在 UI 中使用
class MySettingWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    return settings.when(
      data: (data) => SwitchListTile(
        title: Text('我的新设置'),
        value: data.myNewSetting,
        onChanged: (value) {
          ref.read(settingsProvider.notifier).setMyNewSetting(value);
        },
      ),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

### 2. 添加新的快捷键

```dart
// 在 prompter_screen.dart 的 _handleKeyPress 中添加

void _handleKeyPress(KeyDownEvent keyEvent) {
  // 逻辑按键
  switch (keyEvent.logicalKey) {
    case LogicalKeyboardKey.keyR:  // 新增 R 键
      if (HardwareKeyboard.instance.isControlPressed) {
        // Ctrl+R: 重置提词器
        _scrollableTextController.jumpTo(0);
      }
      break;
    // ... 其他按键
  }
  
  // 物理按键
  switch (keyEvent.physicalKey) {
    case PhysicalKeyboardKey.f5:  // 新增 F5 键
      // F5: 刷新
      ref.invalidate(scriptProvider);
      break;
    // ... 其他按键
  }
}
```

### 3. 添加新的功能特性（付费功能）

```dart
// 1. 在 constants.dart 中定义新功能
enum Feature {
  // ... 现有功能
  myNewFeature,  // 新增
}

// 2. 添加到功能列表
const kAllFeatures = [
  // ... 现有功能
  Feature.myNewFeature,
];

// 3. 添加功能描述（用于国际化）
const kFeatureDescriptions = {
  // ... 现有描述
  Feature.myNewFeature: "my_new_feature_description",
};

// 4. 在翻译文件中添加描述
// assets/translations/zh-CN.json
{
  "my_new_feature_description": "这是我的新功能说明"
}

// 5. 在 UI 中检查功能权限
class MyFeatureWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final features = ref.watch(featuresProvider);
    final isAvailable = features.availableFeatures.contains(
      Feature.myNewFeature
    );
    
    if (!isAvailable) {
      return LockedFeatureWidget(feature: Feature.myNewFeature);
    }
    
    return MyActualFeature();
  }
}
```

### 4. 修改提词器滚动算法

```dart
// 在 scrollable_text.dart 的 _tick() 方法中修改

void _tick() {
  final isUserScrolling = ref.watch(_userScrollingProvider);
  
  // 修改滚动距离计算公式
  // 原始公式：速度 * 字体大小 / 10
  final calculatedScrollOffset =
      (_scrollSpeed * (widget.style?.fontSize ?? 48)) / 10;
  
  // 示例：改为指数增长
  // final calculatedScrollOffset =
  //     pow(_scrollSpeed, 1.2) * (widget.style?.fontSize ?? 48) / 10;
  
  // 示例：添加最小滚动距离
  // final calculatedScrollOffset = max(
  //   2.0,
  //   (_scrollSpeed * (widget.style?.fontSize ?? 48)) / 10
  // );
  
  if (widget.controller.scrollController.hasClients && !isUserScrolling) {
    // ... 滚动逻辑
  }
}
```

### 5. 添加新的翻译语言

```dart
// 1. 创建翻译文件
// assets/translations/ja-JP.json
{
  "title": "Promptify プロンプター",
  "HomeScreen": {
    "TextField_hintText": "スクリプトを入力",
    // ... 其他翻译
  }
}

// 2. 在 constants.dart 中添加支持的语言
const kSupportedLocales = [
  ("English", Locale("en", "US")),
  ("简体中文", Locale("zh", "CN")),
  ("Deutsch", Locale("de", "DE")),
  ("日本語", Locale("ja", "JP")),  // 新增
];

// 3. 重新运行应用，语言选择器会自动显示新语言
```

---

## 🎨 自定义主题

### 修改默认主题色

```dart
// 在 settings_provider.dart 中修改默认值
const _defaultAppPrimaryColor = Color.fromARGB(255, 77, 103, 214);
// 改为你想要的颜色
const _defaultAppPrimaryColor = Color(0xFF00BCD4);  // 青色
```

### 添加预设主题

```dart
// 在 theme_provider.dart 中添加
class ThemePresets {
  static const presets = [
    ('默认蓝', Color(0xFF4D67D6)),
    ('活力橙', Color(0xFFFF9800)),
    ('优雅紫', Color(0xFF9C27B0)),
    ('专业灰', Color(0xFF607D8B)),
  ];
}

// 在设置页面使用
class ThemePresetSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      children: ThemePresets.presets.map((preset) {
        return ActionChip(
          label: Text(preset.$1),
          backgroundColor: preset.$2,
          onPressed: () {
            ref.read(settingsProvider.notifier)
              .setAppPrimaryColor(preset.$2);
          },
        );
      }).toList(),
    );
  }
}
```

---

## 🐛 调试技巧

### 1. 查看 Provider 状态

```dart
// 在开发模式下添加日志
@riverpod
class Prompter extends _$Prompter {
  @override
  PrompterState build() {
    ref.listenSelf((previous, next) {
      // 每次状态变化时打印
      print('Prompter状态变化: $previous → $next');
    });
    return PrompterState();
  }
}
```

### 2. 使用 Riverpod Inspector

```dart
// 在 main.dart 中添加
void main() {
  runApp(
    ProviderScope(
      observers: [
        // 监听所有 Provider 的变化
        ProviderLogger(),
      ],
      child: TeleprompterApp(),
    ),
  );
}

class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print('[${provider.name ?? provider.runtimeType}] $previousValue → $newValue');
  }
}
```

### 3. 调试滚动问题

```dart
// 在 scrollable_text.dart 的 _tick() 中添加
void _tick() {
  // ... 现有代码
  
  // 调试输出
  if (kDebugMode) {
    print('当前滚动位置: ${widget.controller.scrollController.offset}');
    print('滚动速度: $_scrollSpeed');
    print('计算的偏移量: $calculatedScrollOffset');
  }
}
```

---

## 📊 性能优化建议

### 1. 避免不必要的重建

```dart
// ❌ 不好：整个对象变化都会重建
final settings = ref.watch(settingsProvider);

// ✅ 好：只监听需要的字段
final fontSize = ref.watch(
  settingsProvider.select((s) => s.whenData((d) => d.fontSize))
);
```

### 2. 使用 const 构造函数

```dart
// ❌ 不好：每次都创建新对象
return Text('Hello');

// ✅ 好：使用 const
return const Text('Hello');
```

### 3. 合理使用 keepAlive

```dart
// 需要持久化的状态使用 keepAlive
@Riverpod(keepAlive: true)
class Settings extends _$Settings { ... }

// 临时状态不使用 keepAlive（自动释放）
@riverpod
class Prompter extends _$Prompter { ... }
```

### 4. 优化 Drift 查询

```dart
// ❌ 不好：加载所有字段
final scripts = await db.scriptModel.select().get();

// ✅ 好：只加载需要的字段
final scripts = await (db.select(db.scriptModel)
  ..addColumns([
    db.scriptModel.id,
    db.scriptModel.title,
    db.scriptModel.createdAt,
  ])
).get();
```

---

## 🧪 测试

### 单元测试示例

```dart
// test/providers/script_provider_test.dart

void main() {
  group('ScriptProvider Tests', () {
    test('setText 应该更新文本', () {
      final container = ProviderContainer();
      
      // 初始状态
      expect(container.read(scriptProvider).text, '');
      
      // 设置文本
      container.read(scriptProvider.notifier).setText('测试稿件');
      
      // 验证
      expect(container.read(scriptProvider).text, '测试稿件');
      
      container.dispose();
    });
    
    test('setTitle 应该更新标题', () {
      final container = ProviderContainer();
      
      container.read(scriptProvider.notifier).setTitle('我的标题');
      
      expect(container.read(scriptProvider).title, '我的标题');
      
      container.dispose();
    });
  });
}
```

### Widget 测试示例

```dart
// test/ui/screens/home_screen_test.dart

void main() {
  testWidgets('HomeScreen 应该显示输入框', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    
    // 查找输入框
    expect(find.byType(TextField), findsOneWidget);
    
    // 输入文本
    await tester.enterText(find.byType(TextField), '测试文本');
    await tester.pump();
    
    // 验证
    expect(find.text('测试文本'), findsOneWidget);
  });
}
```

---

## 📚 扩展阅读

### 官方文档

- [Flutter 文档](https://flutter.dev/docs)
- [Riverpod 文档](https://riverpod.dev)
- [Freezed 文档](https://pub.dev/packages/freezed)
- [Drift 文档](https://drift.simonbinder.eu)
- [GoRouter 文档](https://pub.dev/packages/go_router)

### 项目相关

- [GitHub 仓库](https://github.com/Tiefseetauchner/tiefprompt)
- [问题追踪](https://github.com/Tiefseetauchner/tiefprompt/issues)
- [贡献指南](https://github.com/Tiefseetauchner/tiefprompt/blob/main/CONTRIBUTING.md)

---

## ❓ 常见问题

### 1. 运行时提示找不到生成的文件

**问题**: `Error: Couldn't find file 'prompter_provider.g.dart'`

**解决**: 运行代码生成
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. CocoaPods 版本冲突（iOS）

**问题**: `CocoaPods could not find compatible versions for pod "sqlite3"`

**解决**:
```bash
cd ios
rm -rf Pods Podfile.lock
pod repo update
pod install
cd ..
flutter run
```

### 3. 设置不生效

**问题**: 修改设置后重启应用，设置丢失

**解决**: 检查 SharedPreferences 是否正确保存
```dart
// 在设置方法中添加日志
Future<void> setFontSize(double fontSize) async {
  final success = await _prefs.setDouble(_fontSizeKey, fontSize);
  print('保存字体大小: $fontSize, 成功: $success');
  // ...
}
```

### 4. 提词器不滚动

**问题**: 点击播放后文本不滚动

**解决**: 
- 检查 `isPlaying` 状态是否为 true
- 检查 Ticker 是否正常启动
- 查看控制台是否有错误日志

```dart
// 在 _tick() 中添加调试
void _tick() {
  print('Tick - isPlaying: ${ref.read(prompterProvider).isPlaying}');
  print('Tick - speed: $_scrollSpeed');
  // ...
}
```

---

## 🎯 下一步学习

1. ✅ 理解项目架构
2. ✅ 掌握核心组件
3. ✅ 学会调试技巧
4. 尝试添加一个简单的新功能
5. 阅读 Riverpod 和 Drift 的进阶文档
6. 为项目做出贡献！

---

祝你开发愉快！有问题随时提问。

