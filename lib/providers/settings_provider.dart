import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiefprompt/providers/prompter_provider.dart';

// 生成的代码文件
part 'settings_provider.freezed.dart'; // Freezed 生成
part 'settings_provider.g.dart';       // Riverpod 生成

/// 默认应用主题色（蓝色）
const _defaultAppPrimaryColor = Color.fromARGB(255, 77, 103, 214);

/// 用户设置状态数据类
/// 
/// 保存用户的所有偏好设置，会持久化到本地存储
/// 启动时从 SharedPreferences 加载，修改时自动保存
@freezed
abstract class SettingsState with _$SettingsState {
  /// 创建设置状态
  /// 
  /// 所有参数都有默认值
  factory SettingsState({
    @Default(1.0) double scrollSpeed,              // 默认滚动速度
    @Default(false) bool mirroredX,                // 默认不镜像X轴
    @Default(false) bool mirroredY,                // 默认不镜像Y轴
    @Default(42.0) double fontSize,                // 默认字体大小42点
    @Default(0.0) double sideMargin,               // 默认侧边距0%
    @Default('Roboto') String fontFamily,          // 默认字体Roboto
    @Default(TextAlign.left) TextAlign alignment,  // 默认左对齐
    @Default(false) bool displayReadingIndicatorBoxes,    // 默认不显示助读区
    @Default(60.0) double readingIndicatorBoxesHeight,    // 助读区高度60%
    @Default(false) bool displayVerticalMarginBoxes,      // 默认不显示遮罩
    @Default(35.0) double verticalMarginBoxesHeight,      // 遮罩高度35%
    @Default(false) bool verticalMarginBoxesFadeEnabled,  // 默认不启用渐变
    @Default(50.0) double verticalMarginBoxesFadeLength,  // 渐变长度50%
    @Default(0.0) double countdownDuration,               // 默认倒计时0秒（不倒计时）
    @Default(ThemeMode.system) ThemeMode themeMode,       // 默认跟随系统主题
    @Default(_defaultAppPrimaryColor) Color appPrimaryColor,      // 应用主题色
    @Default(Colors.black) Color prompterBackgroundColor,         // 提词器背景黑色
    @Default(Colors.white) Color prompterTextColor,               // 提词器文字白色
  }) = _SettingsState;
}

/// 设置服务接口
/// 
/// 定义所有设置相关的操作方法
/// 使用接口可以方便测试和模拟
abstract class ISettings {
  /// 重置所有设置到默认值
  Future<bool> resetSettings();

  // ===== 提词器设置 =====
  Future<void> setScrollSpeed(double speed);                  // 设置滚动速度
  Future<void> setMirroredX(bool value);                      // 设置X轴镜像
  Future<void> setMirroredY(bool value);                      // 设置Y轴镜像
  Future<void> setFontSize(double fontSize);                  // 设置字体大小
  Future<void> setSideMargin(double sideMargin);              // 设置侧边距
  Future<void> setFontFamily(String fontFamily);              // 设置字体
  Future<void> setAlignment(TextAlign alignment);             // 设置对齐方式
  
  // ===== 助读区设置 =====
  Future<void> setDisplayReadingIndicatorBoxes(bool value);   // 显示/隐藏助读区
  Future<void> setReadingIndicatorBoxesHeight(double height); // 设置助读区高度
  
  // ===== 遮罩设置 =====
  Future<void> setDisplayVerticalMarginBoxes(bool value);     // 显示/隐藏遮罩
  Future<void> setVerticalMarginBoxesHeight(double height);   // 设置遮罩高度
  Future<void> setVerticalMarginBoxesFadeEnabled(bool value); // 启用/禁用渐变
  Future<void> setVerticalMarginBoxesFadeLength(double length);  // 设置渐变长度
  
  // ===== 其他设置 =====
  Future<void> setCountdownDuration(double duration);         // 设置倒计时时长
  
  // ===== 主题设置 =====
  Future<void> setThemeMode(ThemeMode themeMode);             // 设置主题模式
  Future<void> setAppPrimaryColor(Color color);               // 设置应用主题色
  Future<void> setPrompterBackgroundColor(Color color);       // 设置提词器背景色
  Future<void> setPrompterTextColor(Color color);             // 设置提词器文字色

  /// 从提词器状态应用设置（保存当前提词器的配置）
  Future<void> applySettingsFromPrompter(PrompterState prompterState);
}

/// 设置管理器
/// 
/// 负责加载、保存和管理所有用户设置
/// - keepAlive: true 表示这个Provider会一直存在，不会被自动释放
/// - 使用 SharedPreferences 持久化存储
@Riverpod(keepAlive: true, dependencies: [])
class Settings extends _$Settings implements ISettings {
  // ===== SharedPreferences 存储键名常量 =====
  static const _speedKey = 'scroll_speed';
  static const _mirroredXKey = 'mirror_text_x';
  static const _mirroredYKey = 'mirror_text_y';
  static const _fontSizeKey = 'font_size';
  static const _sideMarginKey = 'side_margin';
  static const _fontFamilyKey = 'font_family';
  static const _alignmentKey = 'alignment';
  static const _displayReadingIndicatorBoxesKey =
      'display_reading_indicator_boxes';
  static const _readingIndicatorBoxesHeightKey =
      'reading_indicator_boxes_height';
  static const _displayVerticalMarginBoxesKey = 'display_vertical_margin_boxes';
  static const _verticalMarginBoxesHeightKey = 'vertical_margin_boxes_height';
  static const _countdownDurationKey = 'countdown_duration';
  static const _verticalMarginBoxesFadeEnabledKey = 'fade_enabled';
  static const _verticalMarginBoxesFadeLengthKey = 'fade_length';
  static const _themeModeKey = 'theme_mode';
  static const _appPrimaryColorKey = 'app_primary_color';
  static const _prompterBackgroundColorKey = 'prompter_background_color';
  static const _prompterTextColorKey = 'prompter_text_color';

  /// SharedPreferences 实例（延迟初始化）
  late final SharedPreferences _prefs;

  /// 初始化设置并从本地存储加载
  /// 
  /// 这个方法在Provider首次被访问时自动调用
  /// 返回：加载完成的设置状态
  @override
  Future<SettingsState> build() async {
    // 获取 SharedPreferences 实例
    _prefs = await SharedPreferences.getInstance();
    
    // 从本地存储加载所有设置，如果不存在则使用默认值
    return SettingsState().copyWith(
      scrollSpeed: _prefs.getDouble(_speedKey) ?? 1.0,
      mirroredX: _prefs.getBool(_mirroredXKey) ?? false,
      mirroredY: _prefs.getBool(_mirroredYKey) ?? false,
      fontSize: _prefs.getDouble(_fontSizeKey) ?? 42.0,
      sideMargin: _prefs.getDouble(_sideMarginKey) ?? 0.0,
      fontFamily: _prefs.getString(_fontFamilyKey) ?? 'Roboto',
      alignment: _getAlignment(_prefs.getString(_alignmentKey)),
      displayReadingIndicatorBoxes:
          _prefs.getBool(_displayReadingIndicatorBoxesKey) ?? false,
      readingIndicatorBoxesHeight:
          _prefs.getDouble(_readingIndicatorBoxesHeightKey) ?? 60.0,
      displayVerticalMarginBoxes:
          _prefs.getBool(_displayVerticalMarginBoxesKey) ?? false,
      verticalMarginBoxesHeight:
          _prefs.getDouble(_verticalMarginBoxesHeightKey) ?? 35.0,
      verticalMarginBoxesFadeEnabled:
          _prefs.getBool(_verticalMarginBoxesFadeEnabledKey) ?? false,
      verticalMarginBoxesFadeLength:
          _prefs.getDouble(_verticalMarginBoxesFadeLengthKey) ?? 50.0,
      countdownDuration: _prefs.getDouble(_countdownDurationKey) ?? 0.0,
      themeMode: _getThemeMode(_prefs.getString(_themeModeKey)),
      // 颜色需要从ARGB32整数恢复
      appPrimaryColor: Color(
        _prefs.getInt(_appPrimaryColorKey) ??
            _defaultAppPrimaryColor.toARGB32(),
      ),
      prompterBackgroundColor: Color(
        _prefs.getInt(_prompterBackgroundColorKey) ?? Colors.black.toARGB32(),
      ),
      prompterTextColor: Color(
        _prefs.getInt(_prompterTextColorKey) ?? Colors.white.toARGB32(),
      ),
    );
  }

  /// 从字符串解析文本对齐方式
  /// 
  /// [alignment] - 对齐方式字符串（如 "left", "center"）
  /// 返回：TextAlign 枚举，如果无效则返回左对齐
  TextAlign _getAlignment(String? alignment) {
    return TextAlign.values
            .where((element) => element.name == alignment)
            .singleOrNull ??
        TextAlign.left;
  }

  /// 从字符串解析主题模式
  /// 
  /// [themeMode] - 主题模式字符串（如 "light", "dark", "system"）
  /// 返回：ThemeMode 枚举，如果无效则返回跟随系统
  ThemeMode _getThemeMode(String? themeMode) {
    return ThemeMode.values
            .where((element) => element.name == themeMode)
            .singleOrNull ??
        ThemeMode.system;
  }

  /// 重置所有设置到默认值
  /// 
  /// 返回：是否成功清空本地存储
  @override
  Future<bool> resetSettings() async {
    // 更新内存状态为默认值
    state = AsyncData(SettingsState());
    // 清空本地存储
    return await _prefs.clear();
  }

  // ===== 设置更新方法（每个方法都会同时更新内存状态和本地存储）=====

  /// 设置滚动速度
  /// 
  /// [speed] - 新的速度值（行/秒）
  @override
  Future<void> setScrollSpeed(double speed) async {
    await _prefs.setDouble(_speedKey, speed);
    state = state.whenData((s) => s.copyWith(scrollSpeed: speed));
  }

  /// 设置X轴镜像（水平翻转）
  /// 
  /// [value] - 是否启用水平翻转
  @override
  Future<void> setMirroredX(bool value) async {
    await _prefs.setBool(_mirroredXKey, value);
    state = state.whenData((s) => s.copyWith(mirroredX: value));
  }

  /// 设置Y轴镜像（垂直翻转）
  /// 
  /// [value] - 是否启用垂直翻转
  @override
  Future<void> setMirroredY(bool value) async {
    await _prefs.setBool(_mirroredYKey, value);
    state = state.whenData((s) => s.copyWith(mirroredY: value));
  }

  /// 设置是否显示阅读指示框
  /// 
  /// [value] - 是否显示（用于辅助阅读定位）
  @override
  Future<void> setDisplayReadingIndicatorBoxes(bool value) async {
    await _prefs.setBool(_displayReadingIndicatorBoxesKey, value);
    state = state.whenData(
      (s) => s.copyWith(displayReadingIndicatorBoxes: value),
    );
  }

  /// 设置阅读指示框高度
  /// 
  /// [height] - 指示框高度（像素）
  @override
  Future<void> setReadingIndicatorBoxesHeight(double height) async {
    await _prefs.setDouble(_readingIndicatorBoxesHeightKey, height);
    state = state.whenData(
      (s) => s.copyWith(readingIndicatorBoxesHeight: height),
    );
  }

  /// 设置是否显示垂直边距框
  /// 
  /// [value] - 是否显示（用于标记安全区域）
  @override
  Future<void> setDisplayVerticalMarginBoxes(bool value) async {
    await _prefs.setBool(_displayVerticalMarginBoxesKey, value);
    state = state.whenData(
      (s) => s.copyWith(displayVerticalMarginBoxes: value),
    );
  }

  /// 设置垂直边距框高度
  /// 
  /// [height] - 边距框高度（百分比）
  @override
  Future<void> setVerticalMarginBoxesHeight(double height) async {
    await _prefs.setDouble(_verticalMarginBoxesHeightKey, height);
    state = state.whenData(
      (s) => s.copyWith(verticalMarginBoxesHeight: height),
    );
  }

  /// 设置垂直边距框渐变效果是否启用
  /// 
  /// [value] - 是否启用渐变淡化效果
  @override
  Future<void> setVerticalMarginBoxesFadeEnabled(bool value) async {
    await _prefs.setBool(_verticalMarginBoxesFadeEnabledKey, value);
    state = state.whenData(
      (s) => s.copyWith(verticalMarginBoxesFadeEnabled: value),
    );
  }

  /// 设置垂直边距框渐变长度
  /// 
  /// [length] - 渐变区域长度（像素）
  @override
  Future<void> setVerticalMarginBoxesFadeLength(double length) async {
    await _prefs.setDouble(_verticalMarginBoxesFadeLengthKey, length);
    state = state.whenData(
      (s) => s.copyWith(verticalMarginBoxesFadeLength: length),
    );
  }

  /// 设置文本左右边距
  /// 
  /// [sideMargin] - 边距值（像素）
  @override
  Future<void> setSideMargin(double sideMargin) async {
    await _prefs.setDouble(_sideMarginKey, sideMargin);
    state = state.whenData((s) => s.copyWith(sideMargin: sideMargin));
  }

  /// 设置字体家族
  /// 
  /// [fontFamily] - 字体名称（如 "Roboto", "OpenDyslexic"）
  @override
  Future<void> setFontFamily(String fontFamily) async {
    await _prefs.setString(_fontFamilyKey, fontFamily);
    state = state.whenData((s) => s.copyWith(fontFamily: fontFamily));
  }

  /// 设置字体大小
  /// 
  /// [fontSize] - 字体大小（像素）
  @override
  Future<void> setFontSize(double fontSize) async {
    await _prefs.setDouble(_fontSizeKey, fontSize);
    state = state.whenData((s) => s.copyWith(fontSize: fontSize));
  }

  /// 设置文本对齐方式
  /// 
  /// [alignment] - 对齐方式（左对齐、居中、右对齐等）
  @override
  Future<void> setAlignment(TextAlign alignment) async {
    await _prefs.setString(_alignmentKey, alignment.toString());

    state = state.whenData((s) => s.copyWith(alignment: alignment));
  }

  /// 设置倒计时时长
  /// 
  /// [duration] - 播放前的倒计时秒数
  @override
  Future<void> setCountdownDuration(double duration) async {
    await _prefs.setDouble(_countdownDurationKey, duration);
    state = state.whenData((s) => s.copyWith(countdownDuration: duration));
  }

  /// 设置主题模式
  /// 
  /// [themeMode] - 主题模式（亮色、暗色、跟随系统）
  @override
  Future<void> setThemeMode(ThemeMode themeMode) async {
    await _prefs.setString(_themeModeKey, themeMode.name);
    state = state.whenData((s) => s.copyWith(themeMode: themeMode));
  }

  /// 设置应用主题色
  /// 
  /// [color] - 主题颜色（用于界面强调色）
  @override
  Future<void> setAppPrimaryColor(Color color) async {
    await _prefs.setInt(_appPrimaryColorKey, color.toARGB32());
    state = state.whenData((s) => s.copyWith(appPrimaryColor: color));
  }

  /// 设置提词器背景色
  /// 
  /// [color] - 背景颜色
  @override
  Future<void> setPrompterBackgroundColor(Color color) async {
    await _prefs.setInt(_prompterBackgroundColorKey, color.toARGB32());
    state = state.whenData((s) => s.copyWith(prompterBackgroundColor: color));
  }

  /// 设置提词器文字颜色
  /// 
  /// [color] - 文字颜色
  @override
  Future<void> setPrompterTextColor(Color color) async {
    await _prefs.setInt(_prompterTextColorKey, color.toARGB32());
    state = state.whenData((s) => s.copyWith(prompterTextColor: color));
  }

  /// 从提词器状态批量应用设置
  /// 
  /// 这个方法用于在提词器界面调整完参数后，一键保存所有设置
  /// 
  /// [prompterState] - 当前提词器的运行时状态
  @override
  Future<void> applySettingsFromPrompter(PrompterState prompterState) async {
    // 逐个保存所有设置项
    await setScrollSpeed(prompterState.speed);
    await setMirroredX(prompterState.mirroredX);
    await setMirroredY(prompterState.mirroredY);
    await setFontSize(prompterState.fontSize);
    await setSideMargin(prompterState.sideMargin);
    await setFontFamily(prompterState.fontFamily);
    await setAlignment(prompterState.alignment);
    await setDisplayReadingIndicatorBoxes(
      prompterState.displayReadingIndicatorBoxes,
    );
    await setReadingIndicatorBoxesHeight(
      prompterState.readingIndicatorBoxesHeight,
    );
    await setDisplayVerticalMarginBoxes(
      prompterState.displayVerticalMarginBoxes,
    );
    await setVerticalMarginBoxesHeight(prompterState.verticalMarginBoxesHeight);
    await setCountdownDuration(prompterState.countdownDuration);
    await setVerticalMarginBoxesFadeEnabled(
      prompterState.verticalMarginBoxesFadeEnabled,
    );
    await setVerticalMarginBoxesFadeLength(
      prompterState.verticalMarginBoxesFadeLength,
    );
  }
}
