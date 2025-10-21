import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiefprompt/providers/banner_provider.dart';

/// Banner消息监听器组件
///
/// 这个组件包装在每个页面外层，用于监听全局Banner消息
/// 当有错误、提示等消息时，会在页面顶部显示MaterialBanner
///
/// **使用场景**：
/// - 应用内购买错误提示
/// - 功能初始化失败提示
/// - 其他需要全局显示的消息
///
/// **用法**：
/// ```dart
/// BannerListener(
///   child: YourScreen(),
/// )
/// ```
class BannerListener extends ConsumerStatefulWidget {
  /// 子组件（通常是一个屏幕）
  final Widget child;

  const BannerListener({super.key, required this.child});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BannerListenerState();
}

class _BannerListenerState extends ConsumerState<BannerListener> {
  /// Banner消息监听订阅
  ProviderSubscription? _bannerListener;

  @override
  void initState() {
    // 关闭旧的监听器（如果存在）
    _bannerListener?.close();
    
    // 监听bannerMessageProvider的变化
    _bannerListener = ref.listenManual<String?>(bannerMessageProvider, (
      previous,
      next,
    ) {
      final messenger = ScaffoldMessenger.of(context);
      
      if (next != null) {
        // 有新消息，显示MaterialBanner
        messenger.showMaterialBanner(
          MaterialBanner(
            content: Text(next),
            actions: [
              TextButton(
                onPressed: () {
                  // 点击按钮后隐藏Banner并清空消息
                  messenger.hideCurrentMaterialBanner();
                  ref.read(bannerMessageProvider.notifier).state = null;
                },
                child: Text(context.tr("HomeScreen.Understood")),
              ),
            ],
          ),
        );
      } else {
        // 消息为null，隐藏Banner
        messenger.hideCurrentMaterialBanner();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 直接返回子组件，监听器在后台工作
    return widget.child;
  }

  @override
  void dispose() {
    // 释放监听器
    _bannerListener?.close();
    super.dispose();
  }
}
