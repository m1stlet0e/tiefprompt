import 'package:flutter/material.dart';

/// 垂直边距/辅助线组件
///
/// 在提词器界面的顶部和底部显示遮罩区域，有两种用途：
/// 1. **阅读指示框**：半透明的辅助线，帮助用户定位阅读位置
/// 2. **垂直边距框**：不透明的遮罩，标记上下安全区域（可选渐变效果）
///
/// **视觉效果**：
/// - 同时在屏幕顶部和底部显示
/// - 可以配置高度比例
/// - 支持渐变淡化效果（从透明到指定颜色）
///
/// **使用场景**：
/// - 在 prompter_screen.dart 中根据用户设置显示
/// - 阅读指示框：透明度60的前景色
/// - 边距框：不透明的背景色
class VerticalMargin extends StatelessWidget {
  /// 高度比例（0-100）
  /// 实际高度 = 屏幕高度 × (heightRatio / 200)
  /// 除以200是因为顶部和底部各占一半
  final double heightRatio;
  
  /// 遮罩颜色
  final Color color;
  
  /// 是否启用渐变淡化效果
  final bool fade;
  
  /// 渐变长度（0.0-1.0）
  /// 0.0: 无渐变，1.0: 整个区域都是渐变
  final double fadeLength;

  const VerticalMargin({
    super.key,
    required this.heightRatio,
    required this.color,
    this.fade = false,
    this.fadeLength = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    // IgnorePointer: 不拦截触摸事件，让事件穿透到下方的文本
    return IgnorePointer(
      child: Stack(
        children: [
          // 顶部边距框
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _VerticalMarginBox(
              heightRatio: heightRatio,
              color: color,
              fade: fade ? fadeLength : 0,
              fadePosition: _FadePosition.bottom,  // 从上到下渐变
            ),
          ),
          // 底部边距框
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _VerticalMarginBox(
              heightRatio: heightRatio,
              color: color,
              fade: fade ? fadeLength : 0,
              fadePosition: _FadePosition.top,  // 从下到上渐变
            ),
          ),
        ],
      ),
    );
  }
}

/// 单个垂直边距框（内部组件）
///
/// 渲染一个顶部或底部的边距区域，支持渐变效果
class _VerticalMarginBox extends StatelessWidget {
  /// 高度比例
  final double heightRatio;
  
  /// 颜色
  final Color color;
  
  /// 渐变长度（0表示无渐变）
  final double fade;
  
  /// 渐变方向
  final _FadePosition fadePosition;

  const _VerticalMarginBox({
    required this.heightRatio,
    required this.color,
    this.fade = 0,
    this.fadePosition = _FadePosition.top,
  });

  @override
  Widget build(BuildContext context) {
    // 计算实际高度：屏幕高度 × (比例 / 200)
    final height = MediaQuery.of(context).size.height * (heightRatio / 200);
    
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: height,
      child: Container(
        decoration: fade > 0
            // 有渐变效果：使用LinearGradient
            ? BoxDecoration(
                gradient: LinearGradient(
                  // 渐变方向根据位置决定
                  begin: fadePosition == _FadePosition.top
                      ? Alignment.topCenter
                      : Alignment.bottomCenter,
                  end: fadePosition == _FadePosition.top
                      ? Alignment.bottomCenter
                      : Alignment.topCenter,
                  colors: [
                    color.withValues(alpha: 0),    // 起点：完全透明
                    color.withValues(alpha: 1),    // 终点：完全不透明
                  ],
                  stops: [0.0, fade.clamp(0.0, 1.0)],  // 渐变停止点
                ),
              )
            // 无渐变效果：纯色
            : BoxDecoration(color: color),
      ),
    );
  }
}

/// 渐变方向枚举（内部使用）
enum _FadePosition {
  /// 从上到下渐变（顶部边距框）
  top,
  
  /// 从下到上渐变（底部边距框）
  bottom,
}
