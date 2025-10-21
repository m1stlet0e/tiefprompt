import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tiefprompt/providers/settings_provider.dart';

part 'theme_provider.freezed.dart';
part 'theme_provider.g.dart';

/// 主题状态数据类
///
/// 包含应用的所有主题配置
@freezed
abstract class ThemesState with _$ThemesState {
  /// 创建主题状态
  ///
  /// [darkTheme] - 暗色主题
  /// [lightTheme] - 亮色主题
  /// [prompterTheme] - 提词器专用主题（高对比度）
  factory ThemesState({
    required ThemeData darkTheme,
    required ThemeData lightTheme,
    required ThemeData prompterTheme,
  }) = _ThemesState;
}

/// 主题管理器
///
/// 根据用户设置的颜色动态生成应用主题
/// - 依赖 Settings Provider，当颜色设置变化时自动重新构建
/// - keepAlive: true 保证主题始终在内存中
@Riverpod(keepAlive: true, dependencies: [Settings])
class Themes extends _$Themes {
  /// 构建主题配置
  ///
  /// 从设置中读取用户选择的颜色，生成三套主题：
  /// 1. 暗色主题 - 用于应用界面（暗色模式）
  /// 2. 亮色主题 - 用于应用界面（亮色模式）
  /// 3. 提词器主题 - 专门为提词器界面设计的高对比度主题
  @override
  Future<ThemesState> build() async {
    // 监听设置中的主题颜色
    final appPrimaryColor = await ref.watch(
      settingsProvider.selectAsync((s) => s.appPrimaryColor),
    );
    final prompterBackgroundColor = await ref.watch(
      settingsProvider.selectAsync((s) => s.prompterBackgroundColor),
    );
    final prompterTextColor = await ref.watch(
      settingsProvider.selectAsync((s) => s.prompterTextColor),
    );

    return ThemesState(
      // 暗色主题：使用用户选择的主题色
      darkTheme: ThemeData.from(
        colorScheme: ColorScheme.dark(primary: appPrimaryColor),
      ),
      // 亮色主题：使用用户选择的主题色
      lightTheme: ThemeData.from(
        colorScheme: ColorScheme.light(primary: appPrimaryColor),
      ),
      // 提词器专用主题：高对比度暗色主题，使用自定义背景和文字颜色
      prompterTheme: ThemeData.from(
        colorScheme: ColorScheme.highContrastDark(
          primary: appPrimaryColor,
          surface: prompterBackgroundColor,    // 提词器背景色
          onSurface: prompterTextColor,        // 提词器文字颜色
        ),
      ),
    );
  }
}
