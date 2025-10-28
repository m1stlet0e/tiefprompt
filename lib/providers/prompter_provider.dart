import 'dart:async';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:promptify/core/constants.dart';
import 'package:promptify/providers/settings_provider.dart';

// 生成的代码文件
part 'prompter_provider.freezed.dart'; // Freezed 生成的不可变数据类
part 'prompter_provider.g.dart';       // Riverpod 生成的 Provider 代码

/// 提词器运行时状态数据类
/// 
/// 管理提词器的所有实时参数和显示状态
/// 这些状态不会保存到本地，每次启动时从 SettingsProvider 加载
@freezed
abstract class PrompterState with _$PrompterState {
  /// 创建提词器状态
  /// 
  /// 所有参数都有默认值，使用 @Default 注解
  factory PrompterState({
    @Default(1.0) double speed,                      // 滚动速度（行/秒）
    @Default(false) bool mirroredX,                  // X轴镜像（水平翻转）
    @Default(false) bool mirroredY,                  // Y轴镜像（垂直翻转）
    @Default(48.0) double fontSize,                  // 字体大小（点）
    @Default(false) bool isPlaying,                  // 是否正在播放
    @Default(0.0) double sideMargin,                 // 侧边距（百分比）
    @Default('Roboto') String fontFamily,            // 字体系列
    @Default(TextAlign.left) TextAlign alignment,    // 文本对齐方式
    @Default(false) bool displayReadingIndicatorBoxes,  // 是否显示助读区
    @Default(25.0) double readingIndicatorBoxesHeight,  // 助读区高度（百分比）
    @Default(false) bool displayVerticalMarginBoxes,    // 是否显示垂直遮罩
    @Default(25.0) double verticalMarginBoxesHeight,    // 遮罩高度（百分比）
    @Default(5.0) double countdownDuration,             // 倒计时时长（秒）
    @Default(false) bool displayCountdown,              // 是否显示倒计时
    @Default(false) bool verticalMarginBoxesFadeEnabled,  // 是否启用遮罩渐变
    @Default(0.0) double verticalMarginBoxesFadeLength,   // 渐变长度（百分比）
  }) = _PrompterState;
}

/// 提词器状态管理器
/// 
/// 管理提词器的实时状态，包括：
/// - 播放/暂停控制
/// - 速度、字体大小调整
/// - 镜像、对齐等显示设置
/// - 倒计时功能
@riverpod
class Prompter extends _$Prompter {
  /// 倒计时定时器（用于播放前的倒计时）
  Timer? _playPauseTimer;

  /// 初始化状态
  /// 返回默认的提词器状态
  @override
  PrompterState build() {
    return PrompterState();
  }

  /// 从设置中应用配置到提词器
  /// 
  /// [settings] - 用户保存的设置
  /// 
  /// 注意：这里有代码重复，理想情况下应该用更好的方式处理
  /// TODO: 优化这个方法，减少重复代码（DRY原则）
  void applySettings(SettingsState settings) {
    state = state.copyWith(
      speed: settings.scrollSpeed,
      mirroredX: settings.mirroredX,
      mirroredY: settings.mirroredY,
      fontSize: settings.fontSize,
      sideMargin: settings.sideMargin,
      fontFamily: settings.fontFamily,
      alignment: settings.alignment,
      displayReadingIndicatorBoxes: settings.displayReadingIndicatorBoxes,
      readingIndicatorBoxesHeight: settings.readingIndicatorBoxesHeight,
      displayVerticalMarginBoxes: settings.displayVerticalMarginBoxes,
      verticalMarginBoxesHeight: settings.verticalMarginBoxesHeight,
      countdownDuration: settings.countdownDuration,
      verticalMarginBoxesFadeEnabled: settings.verticalMarginBoxesFadeEnabled,
      verticalMarginBoxesFadeLength: settings.verticalMarginBoxesFadeLength,
    );
  }

  /// 设置滚动速度
  /// 
  /// [speed] - 新的滚动速度
  void setSpeed(double speed) {
    state = state.copyWith(speed: speed);
  }

  /// 增加滚动速度
  /// 
  /// [amount] - 增加的量
  /// 如果超过最大速度限制，则不执行
  void increaseSpeed(double amount) {
    if (state.speed + amount > kPrompterMaxSpeed) {
      return; // 已达到最大速度
    }

    state = state.copyWith(speed: state.speed + amount);
  }

  /// 减少滚动速度
  /// 
  /// [amount] - 减少的量
  /// 如果低于最小速度限制，则不执行
  void decreaseSpeed(double amount) {
    if (state.speed - amount < kPrompterMinSpeed) {
      return; // 已达到最小速度
    }

    state = state.copyWith(speed: state.speed - amount);
  }

  /// 切换播放/暂停状态
  /// 
  /// 播放流程：
  /// 1. 显示倒计时
  /// 2. 倒计时结束后开始播放
  /// 
  /// 暂停流程：
  /// 1. 取消倒计时（如果正在倒计时）
  /// 2. 停止播放
  void togglePlayPause() {
    if (state.isPlaying || _playPauseTimer != null) {
      // 如果正在播放或倒计时中，则暂停
      _playPauseTimer?.cancel();
      _playPauseTimer = null;
      state = state.copyWith(displayCountdown: false, isPlaying: false);
    } else {
      // 如果已暂停，则开始倒计时
      state = state.copyWith(displayCountdown: true);
      _playPauseTimer?.cancel();
      _playPauseTimer = Timer(
        Duration(seconds: state.countdownDuration.toInt()),
        () {
          // 倒计时结束，开始播放
          state = state.copyWith(isPlaying: true, displayCountdown: false);
          _playPauseTimer = null;
        },
      );
    }
  }

  /// 切换X轴镜像（水平翻转）
  void toggleMirroredX() {
    state = state.copyWith(mirroredX: !state.mirroredX);
  }

  /// 切换Y轴镜像（垂直翻转）
  void toggleMirroredY() {
    state = state.copyWith(mirroredY: !state.mirroredY);
  }

  /// 切换助读区显示
  void toggleDisplayReadingIndicatorBoxes() {
    state = state.copyWith(
      displayReadingIndicatorBoxes: !state.displayReadingIndicatorBoxes,
    );
  }

  /// 设置助读区高度
  /// 
  /// [height] - 高度百分比（相对于屏幕高度）
  void setReadingIndicatorBoxHeight(double height) {
    state = state.copyWith(readingIndicatorBoxesHeight: height);
  }

  /// 切换垂直遮罩显示
  void toggleDisplayVerticalMarginBoxes() {
    state = state.copyWith(
      displayVerticalMarginBoxes: !state.displayVerticalMarginBoxes,
    );
  }

  /// 设置垂直遮罩高度
  /// 
  /// [height] - 高度百分比（相对于屏幕高度）
  void setVerticalMarginBoxHeight(double height) {
    state = state.copyWith(verticalMarginBoxesHeight: height);
  }

  /// 设置侧边距
  /// 
  /// [sideMargin] - 边距百分比（相对于屏幕宽度）
  void setSideMargin(double sideMargin) {
    state = state.copyWith(sideMargin: sideMargin);
  }

  /// 增加字体大小
  /// 
  /// [amount] - 增加的点数
  /// 如果超过最大字体限制，则不执行
  void increaseFontSize(double amount) {
    if (state.fontSize + amount > kPrompterMaxFontSize) {
      return; // 已达到最大字体大小
    }

    state = state.copyWith(fontSize: state.fontSize + amount);
  }

  /// 减少字体大小
  /// 
  /// [amount] - 减少的点数
  /// 如果低于最小字体限制，则不执行
  void decreaseFontSize(double amount) {
    if (state.fontSize - amount < kPrompterMinFontSize) {
      return; // 已达到最小字体大小
    }

    state = state.copyWith(fontSize: state.fontSize - amount);
  }

  /// 设置字体系列
  /// 
  /// [fontFamily] - 字体名称（如 'Roboto', 'RobotoMono'）
  void setFontFamily(String fontFamily) {
    state = state.copyWith(fontFamily: fontFamily);
  }

  /// 设置文本对齐方式
  /// 
  /// [alignment] - TextAlign 枚举值（left, center, right, justify）
  void setAlignment(TextAlign alignment) {
    state = state.copyWith(alignment: alignment);
  }

  /// 设置倒计时时长
  /// 
  /// [duration] - 倒计时秒数
  void setCountdownDuration(double duration) {
    state = state.copyWith(countdownDuration: duration);
  }

  /// 切换遮罩渐变效果启用状态
  void toggleVerticalMarginBoxesFadeEnabled() {
    state = state.copyWith(
      verticalMarginBoxesFadeEnabled: !state.verticalMarginBoxesFadeEnabled,
    );
  }

  /// 设置遮罩渐变长度
  /// 
  /// [fadeLength] - 渐变长度百分比（相对于屏幕高度）
  void setVerticalMarginBoxesFadeLength(double fadeLength) {
    state = state.copyWith(verticalMarginBoxesFadeLength: fadeLength);
  }
}
