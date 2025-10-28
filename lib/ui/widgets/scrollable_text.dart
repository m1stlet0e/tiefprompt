import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promptify/providers/prompter_provider.dart';

/// 用户手动滚动状态Provider
/// 
/// 当用户手动滚动时设置为 true，防止自动滚动与用户操作冲突
final _userScrollingProvider = StateProvider<bool>((ref) => false);

/// 可滚动文本控制器
/// 
/// 封装 ScrollController，提供便捷的滚动控制方法
class ScrollableTextController {
  /// Flutter 原生滚动控制器
  final ScrollController scrollController;

  /// 构造函数
  /// 
  /// [initialScrollOffset] - 初始滚动位置（默认0.0）
  ScrollableTextController({double initialScrollOffset = 0.0})
      : scrollController =
            ScrollController(initialScrollOffset: initialScrollOffset);

  /// 跳转到指定位置（无动画）
  /// 
  /// [offset] - 目标滚动位置（像素）
  void jumpTo(double offset) {
    scrollController.jumpTo(offset);
  }

  /// 相对当前位置跳转
  /// 
  /// [offset] - 相对偏移量（正数向下，负数向上）
  void jumpRelative(double offset) {
    scrollController.jumpTo(scrollController.offset + offset);
  }

  /// 释放资源
  void dispose() {
    scrollController.dispose();
  }
}

/// 可自动滚动的文本组件
/// 
/// 这是提词器的核心组件，实现了平滑的自动滚动效果
/// 
/// 主要功能：
/// - 根据速度自动滚动文本
/// - 支持用户手动滚动（自动滚动会暂停）
/// - 支持X/Y轴镜像（配合分光镜使用）
/// - 到达末尾自动停止
class ScrollableText extends ConsumerStatefulWidget {
  /// 滚动控制器
  final ScrollableTextController controller;
  
  /// 要显示的文本内容
  final String text;
  
  /// 文本样式（字体、大小、颜色等）
  final TextStyle? style;
  
  /// 侧边距（左右）
  final double sideMargin;

  const ScrollableText({
    super.key,
    required this.text,
    this.style,
    required this.sideMargin,
    required this.controller,
  });

  @override
  ConsumerState<ScrollableText> createState() => _ScrollableTextState();
}

class _ScrollableTextState extends ConsumerState<ScrollableText>
    with SingleTickerProviderStateMixin { // 混入 Ticker 支持，用于帧率同步
  /// 帧率同步器（与屏幕刷新同步，通常60fps）
  Ticker? _ticker;
  
  /// 当前滚动速度
  double _scrollSpeed = 0;
  
  /// 到达末尾时的回调函数
  Function? _onReachedEnd;

  /// 开始自动滚动
  /// 
  /// [speed] - 滚动速度
  void _startScrolling(double speed) {
    _stopScrolling();        // 先停止之前的滚动
    _scrollSpeed = speed;    // 设置新速度
    _ticker?.start();        // 启动Ticker
  }

  /// 停止自动滚动
  void _stopScrolling() {
    _ticker?.stop();
  }

  @override
  void initState() {
    super.initState();

    // 创建 Ticker，每次屏幕刷新都会调用 _tick() 方法
    // Ticker 与显示器刷新率同步（通常60fps），保证流畅的动画效果
    _ticker = createTicker((Duration elapsed) {
      _tick(); // 每帧执行一次
    });
  }

  /// 每帧执行的滚动逻辑
  /// 
  /// 这个方法会在屏幕每次刷新时被调用（约60次/秒）
  /// 负责计算并执行自动滚动
  void _tick() {
    // 检查用户是否正在手动滚动
    final isUserScrolling = ref.watch(_userScrollingProvider);

    // 计算本帧应该滚动的距离
    // 公式：(速度 * 字体大小) / 10
    // 
    // 为什么要乘以字体大小？
    // - 字体越大，相同速度下应该滚动更快，保持视觉速度一致
    // 例如：字体48，速度1.0 → 每帧滚动4.8像素
    //      字体96，速度1.0 → 每帧滚动9.6像素（正好2倍）
    final calculatedScrollOffset =
        (_scrollSpeed * (widget.style?.fontSize ?? 48)) / 10;

    // 只在满足以下条件时执行滚动：
    // 1. 滚动控制器已连接到 Widget
    // 2. 用户没有手动滚动
    if (widget.controller.scrollController.hasClients && !isUserScrolling) {
      // 检查是否即将到达末尾
      if (widget.controller.scrollController.position.pixels +
              calculatedScrollOffset >=
          widget.controller.scrollController.position.maxScrollExtent) {
        // 到达末尾，触发回调（通常是自动暂停）
        _onReachedEnd?.call();
        return;
      }

      // 执行平滑滚动动画
      widget.controller.scrollController.animateTo(
          widget.controller.scrollController.position.pixels +
              calculatedScrollOffset,  // 目标位置 = 当前位置 + 偏移量
          duration: Duration(milliseconds: 100),  // 动画时长100ms
          curve: Curves.linear);  // 线性插值（匀速）
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕高度（用于padding和"The End"占位）
    final mediaHeight = MediaQuery.of(context).size.height;

    // 在第一帧渲染后设置手动滚动监听器
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // 监听滚动控制器的滚动状态
      widget.controller.scrollController.position.isScrollingNotifier
          .addListener(() {
        // 当用户手动滚动时，更新状态
        // 这会阻止自动滚动与用户操作冲突
        ref.read(_userScrollingProvider.notifier).state = widget
            .controller.scrollController.position.isScrollingNotifier.value;
      });
    });

    // 监听提词器状态
    final prompter = ref.watch(prompterProvider);

    // 设置到达末尾的回调：自动暂停播放
    _onReachedEnd = () {
      ref.read(prompterProvider.notifier).togglePlayPause();
    };

    // 根据播放状态启动或停止滚动
    if (prompter.isPlaying) {
      _startScrolling(prompter.speed);  // 播放中，启动滚动
    } else {
      _stopScrolling();  // 暂停中，停止滚动
    }
    
    // 构建UI
    return Transform.flip(
        flipX: prompter.mirroredX,  // X轴镜像（水平翻转）
        flipY: prompter.mirroredY,  // Y轴镜像（垂直翻转）
        child: SingleChildScrollView(
          controller: widget.controller.scrollController,
          // 上方padding等于屏幕高度，使文本初始位置在屏幕中央
          padding: EdgeInsets.fromLTRB(
              widget.sideMargin,   // 左边距
              mediaHeight,         // 上边距（屏幕高度）
              widget.sideMargin,   // 右边距
              0),                  // 下边距
          child: Column(children: [
            // 主文本内容
            Text(
              widget.text,
              style: widget.style,
              textAlign: prompter.alignment,  // 文本对齐方式
            ),
            // "The End" 提示（占据一个屏幕高度，使文本可以完全滚出屏幕）
            SizedBox(
                height: mediaHeight,
                child: Center(child: Text("The End", style: widget.style))),
          ]),
        ));
  }

  @override
  void dispose() {
    // 清理资源
    _stopScrolling();      // 停止滚动
    _ticker?.dispose();    // 释放Ticker
    _ticker = null;
    super.dispose();
  }
}
