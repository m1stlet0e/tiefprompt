import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiefprompt/providers/script_provider.dart';

/// 提词器顶部控制栏
///
/// 显示在提词器界面的顶部，包含：
/// - 关闭按钮：返回主页
/// - 稿件标题：显示当前播放的稿件名称
///
/// **可见性**：
/// 由 prompter_screen.dart 中的 controlsVisibleProvider 控制
/// 点击屏幕或按Tab键可以显示/隐藏
class PrompterTopBar extends ConsumerWidget {
  const PrompterTopBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final script = ref.watch(scriptProvider);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        // 半透明背景，不影响文本可读性
        color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            // 关闭按钮
            IconButton(
              icon: Icon(Icons.close,
                  color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            ),
            // 稿件标题（自动省略过长文本）
            Expanded(
              child: Text(
                script.title ?? context.tr("empty_title"),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
