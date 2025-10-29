# 项目重命名总结：tiefprompt → Promptify

## 完成日期
2025-10-29

## 变更概述
项目已从 **tiefprompt** 正式重命名为 **Promptify**。所有相关的包名、应用名、配置文件和源代码都已更新。

## 更新的文件清单

### Flutter/Dart 配置
- ✅ **pubspec.yaml**
  - 项目名称：`name: promptify`
  - 包标识：`identity_name: io.github.tiefseetauchner.promptify`

- ✅ **lib/models/database.dart**
  - 数据库文件名：`name: 'promptify'`

- ✅ **lib/core/constants.dart**
  - 专业版产品 ID：`kProId = "io.github.tiefseetauchner.promptify.pro"`

- ✅ **build.yaml**
  - Drift 数据库配置：`promptify: lib/models/database.dart`

### iOS 配置
- ✅ **ios/Runner.xcodeproj/project.pbxproj**
  - 所有 `com.tiefprompt` → `com.promptify`
  - 所有 `io.github.tiefseetauchner.tiefprompt` → `io.github.tiefseetauchner.promptify`
  - 测试目标 Bundle ID 已更新

- ✅ **macos/Runner/Configs/AppInfo.xcconfig**
  - 应用名称：`PRODUCT_NAME = promptify`
  - Bundle 标识：`PRODUCT_BUNDLE_IDENTIFIER = io.github.tiefseetauchner.promptify`

- ✅ **macos/Runner.xcodeproj/** 文件
  - project.pbxproj：所有包名和应用名称已更新
  - xcschemes/Runner.xcscheme：应用名称已更新
  - Release.entitlements：Bundle ID 已更新

### Android 配置
- ✅ **android/app/build.gradle**
  - namespace：`io.github.tiefseetauchner.promptify`
  - applicationId：`io.github.tiefseetauchner.promptify`

- ✅ **android/app/src/main/kotlin/**
  - 包目录已重组织：`io/github/tiefseetauchner/promptify/`
  - MainActivity.kt 已移至新位置并更新包声明

### Windows 配置
- ✅ **windows/CMakeLists.txt**
  - 项目名：`project(promptify LANGUAGES CXX)`
  - 二进制名：`set(BINARY_NAME "promptify")`

- ✅ **windows/runner/main.cpp**
  - 窗口标题：`L"promptify"`

- ✅ **windows/runner/Runner.rc**
  - FileDescription、InternalName、OriginalFilename、ProductName 已更新

### Linux 配置
- ✅ **linux/CMakeLists.txt**
  - 二进制名：`set(BINARY_NAME "promptify")`
  - 应用 ID：`set(APPLICATION_ID "io.github.tiefseetauchner.promptify")`

- ✅ **linux/runner/my_application.cc**
  - 窗口标题：`"promptify"`（两处）

### 其他工具
- ✅ **tools/package.sh**
  - Docker 镜像：`tiefseetauchner/promptify-build:latest`
  - 容器名称：`promptify_build_container`

## 核心包名变更

| 旧包名 | 新包名 |
|--------|--------|
| `io.github.tiefseetauchner.tiefprompt` | `io.github.tiefseetauchner.promptify` |
| `com.tiefprompt.app` | `com.promptify.app` |
| `package:tiefprompt` | `package:promptify` |

## 产品 ID 变更
- **旧**：`io.github.tiefseetauchner.tiefprompt.pro`
- **新**：`io.github.tiefseetauchner.promptify.pro`

## 数据库文件名变更
- **旧**：`tiefprompt`
- **新**：`promptify`

## 验证清单
- ✅ 所有 Dart 导入已更新为 `package:promptify`
- ✅ Android 包目录已完全重组织
- ✅ 所有平台的应用 ID/Bundle ID 已更新
- ✅ 数据库配置已更新
- ✅ 构建脚本和工具已更新
- ✅ 无残留的 "tiefprompt" 引用在源代码中（除了自动生成的文件路径）

## 后续步骤
1. 运行 `flutter clean && flutter pub get` 以清理旧的构建缓存
2. 在 iOS 中运行 `pod install --repo-update`
3. 测试在所有平台（iOS、Android、macOS、Linux、Windows）上构建
4. 更新应用商店配置和版本说明

## 注意事项
- 由于包名已更改，现有用户需要卸载旧应用并安装新版本
- 数据库文件名已更改，可能需要迁移逻辑来处理旧数据
- 所有 InApp 购买产品 ID 已更新
