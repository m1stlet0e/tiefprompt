# 自动生成文件说明 (.g.dart 和 .freezed.dart)

## 📋 目录
1. [什么是生成文件？](#什么是生成文件)
2. [.g.dart 文件详解](#g-dart-文件详解)
3. [.freezed.dart 文件详解](#freezed-dart-文件详解)
4. [如何生成这些文件](#如何生成这些文件)
5. [项目中的生成文件清单](#项目中的生成文件清单)

---

## 什么是生成文件？

在 Flutter/Dart 项目中，有些重复性的代码可以通过**代码生成器**自动创建，而不需要手写。这些自动生成的文件通常以特定后缀结尾：

- **`.g.dart`** - 通用代码生成文件
- **`.freezed.dart`** - Freezed 包生成的不可变数据类

### ⚠️ 重要规则
1. **永远不要手动编辑这些文件**（文件开头都有 `GENERATED CODE - DO NOT MODIFY BY HAND`）
2. 这些文件**不应该添加注释**（因为会被覆盖）
3. 这些文件**应该提交到 Git**（方便团队协作）
4. 修改源文件后需要**重新生成**这些文件

---

## .g.dart 文件详解

### 用途
`.g.dart` 文件是由 **`build_runner`** 根据注解自动生成的代码，主要用于：

1. **Drift (数据库)** - 生成数据库表、查询方法
2. **Riverpod (状态管理)** - 生成 Provider 实现
3. **JSON 序列化** - 生成 toJson/fromJson 方法（本项目未使用）

---

### 示例 1：database.g.dart (Drift 数据库)

#### 你写的源文件 (database.dart)：
```dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:tiefprompt/models/script_model.dart';

part 'database.g.dart';  // ← 告诉 Dart 这里会有生成文件

/// 应用数据库类
@DriftDatabase(tables: [ScriptModel])  // ← 注解：生成数据库代码
class AppDatabase extends _$AppDatabase {  // ← 继承生成的类
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'tiefprompt',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
```

#### 自动生成的 database.g.dart 包含：
```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// 生成的数据库基类
abstract class _$AppDatabase extends GeneratedDatabase {
  // ... 500+ 行自动生成的代码

  // 1. 表定义
  $ScriptModelTable get scriptModel => ...;
  
  // 2. 管理器 API
  DatabaseManager get managers => ...;
  
  // 3. SQL 查询方法
  Selectable<ScriptModelData> select() => ...;
  Future<int> insert() => ...;
  Future<int> update() => ...;
  Future<int> delete() => ...;
  
  // 4. 数据验证
  // 5. 类型转换
  // 6. 流式查询支持
  // ... 等等
}
```

**好处**：
- ✅ 你只需写 20 行代码
- ✅ 自动生成 500+ 行类型安全的数据库代码
- ✅ 避免手写 SQL 字符串
- ✅ 编译时类型检查

---

### 示例 2：script_provider.g.dart (Riverpod Provider)

#### 你写的源文件 (script_provider.dart)：
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'script_provider.g.dart';  // ← 生成文件声明

/// 稿件状态管理器
@riverpod  // ← 注解：生成 Provider 代码
class Script extends _$Script {
  @override
  ScriptState build() => ScriptState(text: "", title: null);

  void setText(String text) {
    state = state.copyWith(text: text);
  }
  
  void setTitle(String title) {
    state = state.copyWith(title: title);
  }
}
```

#### 自动生成的 script_provider.g.dart 包含：
```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'script_provider.dart';

// 生成的 Provider 实现
final scriptProvider = NotifierProvider<Script, ScriptState>(() {
  return Script();
});

// 生成的基类
abstract class _$Script extends Notifier<ScriptState> {
  // Provider 生命周期管理
  // 依赖注入支持
  // 状态更新通知
  // ... 等等
}
```

**好处**：
- ✅ 自动处理 Provider 注册
- ✅ 自动管理依赖关系
- ✅ 类型安全的状态访问
- ✅ 减少样板代码

---

## .freezed.dart 文件详解

### 用途
`.freezed.dart` 文件是由 **`freezed`** 包生成的，用于创建**不可变数据类**（Immutable Data Classes）。

### 为什么需要不可变数据类？
在 Flutter 状态管理中，数据不可变性非常重要：
- ✅ 防止意外修改状态
- ✅ 便于状态对比（==）
- ✅ 便于调试（toString）
- ✅ 安全的状态复制（copyWith）

---

### 示例：combining_provider.freezed.dart

#### 你写的源文件 (combining_provider.dart)：
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'combining_provider.freezed.dart';  // ← 生成文件声明

/// 组合状态数据类
@freezed  // ← 注解：生成不可变数据类
abstract class CombinedState with _$CombinedState {
  /// 创建组合状态
  factory CombinedState(List<Object> states) = _CombinedState;
}
```

只需 7 行代码！

#### 自动生成的 combining_provider.freezed.dart 包含：
```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combining_provider.dart';

// 1. copyWith 方法 - 创建副本
mixin _$CombinedState {
  List<Object> get states;
  
  CombinedState copyWith({List<Object>? states}) {
    return CombinedState(states ?? this.states);
  }
}

// 2. == 运算符 - 值比较
@override
bool operator ==(Object other) {
  return identical(this, other) || 
    (other is CombinedState && 
     DeepCollectionEquality().equals(states, other.states));
}

// 3. hashCode - 哈希计算
@override
int get hashCode => DeepCollectionEquality().hash(states);

// 4. toString - 字符串表示
@override
String toString() => 'CombinedState(states: $states)';

// 5. 具体实现类
class _CombinedState implements CombinedState {
  final List<Object> states;
  const _CombinedState(this.states);
  // ... 实现所有方法
}

// ... 总共 200+ 行代码
```

**好处**：
- ✅ 你写 7 行，自动生成 200+ 行
- ✅ 不可变性保证（所有字段都是 final）
- ✅ 值比较（可以用 == 比较内容）
- ✅ 便捷的复制方法（copyWith）
- ✅ 调试友好（toString 自动实现）
- ✅ 模式匹配支持（when/map）

---

### 更复杂的 Freezed 示例：PrompterState

```dart
// 你写的代码：
@freezed
abstract class PrompterState with _$PrompterState {
  factory PrompterState({
    @Default(1.0) double speed,
    @Default(false) bool mirroredX,
    @Default(false) bool mirroredY,
    @Default(42.0) double fontSize,
    // ... 更多字段
  }) = _PrompterState;
}

// Freezed 自动生成：
// - 构造函数（所有参数都有默认值）
// - copyWith（可以只修改部分字段）
// - == 和 hashCode（基于所有字段）
// - toString（漂亮的打印格式）
```

使用示例：
```dart
// 创建初始状态
final state = PrompterState();

// 创建修改后的副本（原对象不变）
final newState = state.copyWith(speed: 2.0);

// 值比较
print(state == newState);  // false

// 调试打印
print(state);
// PrompterState(speed: 1.0, mirroredX: false, mirroredY: false, ...)
```

---

## 如何生成这些文件

### 命令 1：一次性生成
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- `build` - 构建生成文件
- `--delete-conflicting-outputs` - 删除冲突的旧文件

**使用场景**：
- ✅ 克隆项目后首次运行
- ✅ 修改了注解代码后
- ✅ 合并代码后有冲突

---

### 命令 2：监听模式（开发推荐）
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

- `watch` - 监听文件变化，自动重新生成
- 修改源文件后，几秒钟内自动更新生成文件

**使用场景**：
- ✅ 开发过程中频繁修改代码
- ✅ 避免每次手动运行命令

---

### 命令 3：清理后重新生成
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

**使用场景**：
- ✅ 生成文件出现问题
- ✅ 升级了代码生成器版本

---

## 项目中的生成文件清单

### Drift 数据库生成文件 (1个)
```
lib/models/
  ├── database.dart              ← 源文件
  └── database.g.dart            ← 生成文件 (500+ 行)
```

### Riverpod Provider 生成文件 (12个)
```
lib/providers/
  ├── script_provider.dart             ← 源文件
  ├── script_provider.g.dart           ← 生成文件
  ├── prompter_provider.dart           ← 源文件
  ├── prompter_provider.g.dart         ← 生成文件
  ├── settings_provider.dart           ← 源文件
  ├── settings_provider.g.dart         ← 生成文件
  ├── theme_provider.dart              ← 源文件
  ├── theme_provider.g.dart            ← 生成文件
  ├── router_provider.dart             ← 源文件
  ├── router_provider.g.dart           ← 生成文件
  ├── feature_provider.dart            ← 源文件
  ├── feature_provider.g.dart          ← 生成文件
  ├── combining_provider.dart          ← 源文件
  └── combining_provider.g.dart        ← 生成文件

lib/services/
  ├── script_service.dart              ← 源文件
  └── script_service.g.dart            ← 生成文件
```

### Freezed 数据类生成文件 (6个)
```
lib/providers/
  ├── script_provider.dart             ← 源文件
  ├── script_provider.freezed.dart     ← 生成文件 (200+ 行)
  ├── prompter_provider.dart           ← 源文件
  ├── prompter_provider.freezed.dart   ← 生成文件 (300+ 行)
  ├── settings_provider.dart           ← 源文件
  ├── settings_provider.freezed.dart   ← 生成文件 (400+ 行)
  ├── theme_provider.dart              ← 源文件
  ├── theme_provider.freezed.dart      ← 生成文件
  ├── combining_provider.dart          ← 源文件
  ├── combining_provider.freezed.dart  ← 生成文件
  ├── app_features.dart                ← 源文件
  └── app_features.freezed.dart        ← 生成文件
```

### 总计
- **源文件**: ~30 个
- **生成文件**: ~40 个
- **生成代码总量**: 约 10,000+ 行

如果没有代码生成，你需要手写这 10,000+ 行重复代码！

---

## 常见问题 FAQ

### Q1: 为什么生成文件要提交到 Git？
**A**: 
- ✅ 团队成员可以直接运行项目，无需先生成
- ✅ CI/CD 流程更简单
- ✅ 代码审查时可以看到生成代码的变化

有些项目选择不提交，但 Flutter 官方推荐提交。

---

### Q2: 修改了源文件但生成文件没更新？
**A**: 手动运行生成命令：
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

或者使用 watch 模式：
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

---

### Q3: 生成文件报错怎么办？
**A**: 
1. 检查源文件语法是否正确
2. 确保添加了 `part 'xxx.g.dart';` 声明
3. 清理后重新生成：
   ```bash
   flutter pub run build_runner clean
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

---

### Q4: 可以手动编辑生成文件吗？
**A**: 
❌ **绝对不行！** 

- 文件开头就写着 `DO NOT MODIFY BY HAND`
- 下次生成时你的修改会被覆盖
- 应该修改源文件，然后重新生成

---

### Q5: build_runner 很慢怎么办？
**A**: 
1. 使用 watch 模式（只重新生成修改的文件）
2. 关闭不必要的代码生成器
3. 升级到最新版本的依赖
4. 考虑使用更快的电脑 😄

---

## 总结

### .g.dart 文件
- 📦 **用途**: 通用代码生成（数据库、Provider、JSON等）
- 🔧 **生成器**: build_runner + 各种生成器插件
- 💡 **好处**: 减少样板代码，类型安全

### .freezed.dart 文件
- 📦 **用途**: 不可变数据类
- 🔧 **生成器**: freezed 包
- 💡 **好处**: 值比较、copyWith、toString 等

### 核心原则
1. ❌ **永远不要手动编辑生成文件**
2. ✅ **修改源文件后重新生成**
3. ✅ **将生成文件提交到 Git**
4. ✅ **使用 watch 模式提高开发效率**

---

## 相关资源

- [Drift 官方文档](https://drift.simonbinder.eu/)
- [Riverpod 代码生成文档](https://riverpod.dev/docs/concepts/about_code_generation)
- [Freezed 官方文档](https://pub.dev/packages/freezed)
- [build_runner 使用指南](https://pub.dev/packages/build_runner)

---

**最后提醒**: 这些生成文件是项目的重要组成部分，虽然不需要手动编辑，但理解它们的作用有助于你更好地使用 Flutter 开发！


