import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:promptify/providers/prompter_provider.dart';
import 'package:promptify/providers/settings_provider.dart';
import 'package:promptify/ui/widgets/countdown_timer.dart';
import 'package:promptify/ui/widgets/prompter_bottom_bar.dart';
import 'package:promptify/ui/widgets/prompter_top_bar.dart';
import 'package:promptify/ui/widgets/vertical_margin.dart';
import 'package:promptify/ui/widgets/scrollable_text.dart';
import 'package:promptify/providers/script_provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// 控制栏可见性Provider
///
/// 用于切换提词器界面顶部和底部控制栏的显示/隐藏
final controlsVisibleProvider = StateProvider<bool>((ref) => true);

/// 提词器屏幕
///
/// 应用的核心功能界面，用于播放稿件
/// 
/// **主要功能**：
/// - 自动滚动文本显示
/// - 键盘快捷键控制（播放/暂停、速度、字体大小等）
/// - 屏幕常亮（播放时）
/// - 横屏显示
/// - 可自定义的阅读辅助线和边距
/// - 倒计时功能
///
/// **键盘快捷键**：
/// - 空格/回车: 播放/暂停
/// - 上/下箭头: 滚动文本
/// - PageUp/PageDown: 翻页
/// - Home/End: 跳到开头/结尾
/// - +/-: 调整速度（Ctrl + +/- 调整字体）
/// - Tab: 显示/隐藏控制栏
/// - Ctrl+S: 保存当前设置
/// - Ctrl+.: 打开设置
class PrompterScreen extends ConsumerStatefulWidget {
  const PrompterScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PrompterScreenState();
}

class _PrompterScreenState extends ConsumerState<PrompterScreen> {
  /// 键盘焦点节点，用于监听键盘事件
  final _focusNode = FocusNode();
  
  /// 滚动文本控制器
  late final ScrollableTextController _scrollableTextController;

  @override
  void initState() {
    super.initState();
    _scrollableTextController = ScrollableTextController();
    
    // 启用屏幕常亮（防止播放时息屏）
    WakelockPlus.enable();

    // 在第一帧渲染后将滚动位置初始化到屏幕中间
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollableTextController.scrollController.hasClients) {
        _scrollableTextController.jumpTo(
          MediaQuery.of(context).size.height / 2,
        );
      }
    });

    // 从设置中应用初始配置到提词器
    ref.read(settingsProvider).whenData((data) {
      ref.read(prompterProvider.notifier).applySettings(data);
    });
  }

  /// 构建提词器界面
  @override
  Widget build(BuildContext context) {
    final script = ref.watch(scriptProvider);
    final controlsVisible = ref.watch(controlsVisibleProvider);

    // 强制横屏显示
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // 设置沉浸式模式（隐藏系统UI）
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

    // 监听设置变化，自动应用到提词器
    ref.listen(settingsProvider, (previous, next) async {
      next.whenData((data) {
        ref.read(prompterProvider.notifier).applySettings(data);
      });
    });

    final prompter = ref.watch(prompterProvider);

    // 播放时保持屏幕常亮，暂停时允许息屏
    if (prompter.isPlaying) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }

    return KeyboardListener(
      // 键盘事件处理
      onKeyEvent: (keyEvent) {
        if (keyEvent is KeyDownEvent) {
          // 逻辑按键处理（与键盘布局无关）
          switch (keyEvent.logicalKey) {
            case LogicalKeyboardKey.enter:
            case LogicalKeyboardKey.space:
              // 播放/暂停
              ref.read(prompterProvider.notifier).togglePlayPause();
              break;
            case LogicalKeyboardKey.arrowUp:
              // 向上滚动
              _scrollableTextController.jumpRelative(-75);
              break;
            case LogicalKeyboardKey.arrowDown:
              // 向下滚动
              _scrollableTextController.jumpRelative(75);
              break;
            case LogicalKeyboardKey.pageUp:
              // 向上翻页
              _scrollableTextController.jumpRelative(
                -MediaQuery.of(context).size.height,
              );
              break;
            case LogicalKeyboardKey.pageDown:
              // 向下翻页
              _scrollableTextController.jumpRelative(
                MediaQuery.of(context).size.height,
              );
              break;
            case LogicalKeyboardKey.home:
              // 跳到开头
              _scrollableTextController.jumpTo(0);
              break;
            case LogicalKeyboardKey.end:
              // 跳到结尾
              _scrollableTextController.jumpTo(
                _scrollableTextController
                    .scrollController
                    .position
                    .maxScrollExtent,
              );
              break;
            case LogicalKeyboardKey.tab:
              // 切换控制栏显示
              ref.read(controlsVisibleProvider.notifier).state =
                  !controlsVisible;
              break;
          }

          // 物理按键处理（与键盘布局相关）
          switch (keyEvent.physicalKey) {
            case PhysicalKeyboardKey.equal:
            case PhysicalKeyboardKey.numpadAdd:
              // +键：增加速度（Ctrl+加号：增加字体）
              if (HardwareKeyboard.instance.isControlPressed) {
                ref.read(prompterProvider.notifier).increaseFontSize(1);
              } else {
                ref.read(prompterProvider.notifier).increaseSpeed(.1);
              }
              break;
            case PhysicalKeyboardKey.minus:
            case PhysicalKeyboardKey.numpadSubtract:
              // -键：减少速度（Ctrl+减号：减少字体）
              if (HardwareKeyboard.instance.isControlPressed) {
                ref.read(prompterProvider.notifier).decreaseFontSize(1);
              } else {
                ref.read(prompterProvider.notifier).decreaseSpeed(.1);
              }
              break;
            case PhysicalKeyboardKey.period:
              // Ctrl+.: 打开设置
              if (HardwareKeyboard.instance.isControlPressed) {
                context.push('/settings');
              }
              break;
          }

          // 字符按键处理
          switch (keyEvent.character) {
            case "s":
              // Ctrl+S: 保存当前设置
              if (HardwareKeyboard.instance.isControlPressed) {
                ref
                    .read(settingsProvider.notifier)
                    .applySettingsFromPrompter(prompter);
              }
              break;
          }
        }
      },
      focusNode: _focusNode,
      autofocus: true,  // 自动获取焦点以接收键盘事件
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () {
                ref.read(controlsVisibleProvider.notifier).state =
                    !controlsVisible;
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ScrollableText(
                  controller: _scrollableTextController,
                  text: script.text,
                  style: TextStyle(
                    fontSize: prompter.fontSize,
                    fontFamily: prompter.fontFamily,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  sideMargin:
                      (MediaQuery.of(context).size.width / 2) *
                      (prompter.sideMargin / 100),
                ),
              ),
            ),
            if (prompter.displayVerticalMarginBoxes)
              VerticalMargin(
                heightRatio: prompter.verticalMarginBoxesHeight,
                color: Theme.of(context).canvasColor,
                fade: prompter.verticalMarginBoxesFadeEnabled,
                // NOTE: fadeLength should be normalized to [0, 1]
                fadeLength: prompter.verticalMarginBoxesFadeLength / 100,
              ),
            if (prompter.displayReadingIndicatorBoxes)
              VerticalMargin(
                heightRatio: prompter.readingIndicatorBoxesHeight,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(60),
              ),
            if (controlsVisible) PrompterTopBar(),
            if (controlsVisible) PrompterBottomBar(),
            if (prompter.displayCountdown && prompter.countdownDuration > 0)
              CountdownTimer(duration: prompter.countdownDuration.toInt()),
          ],
        ),
      ),
    );
  }

  /// 清理资源
  @override
  void dispose() {
    // 恢复屏幕方向自由旋转
    SystemChrome.setPreferredOrientations([]);
    // 恢复系统UI显示
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    // 禁用屏幕常亮
    WakelockPlus.disable();
    // 释放焦点节点
    _focusNode.dispose();
    // 释放滚动控制器
    _scrollableTextController.dispose();
    super.dispose();
  }
}
