import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:promptify/providers/theme_provider.dart';
import 'package:promptify/ui/screens/home_screen.dart';
import 'package:promptify/ui/screens/open_file_screen.dart';
import 'package:promptify/ui/screens/prompter_screen.dart';
import 'package:promptify/ui/screens/settings_screen.dart';
import 'package:promptify/ui/screens/profile_screen.dart';
import 'package:promptify/ui/widgets/banner_listener.dart';

part 'router_provider.g.dart';

/// 路由配置管理器
///
/// 使用 GoRouter 管理应用的所有页面路由
/// - keepAlive: true 保证路由配置在应用生命周期内一直存在
/// - 依赖 Themes Provider，用于为提词器页面应用专用主题
@Riverpod(keepAlive: true, dependencies: [Themes])
class PromptifyRouter extends _$PromptifyRouter {
  /// 构建路由配置
  ///
  /// 定义应用的所有页面路径和对应的 Widget
  @override
  GoRouter build() {
    return GoRouter(
      initialLocation: '/',  // 应用启动时的初始路由
      routes: [
        // 主页：显示稿件列表和输入框
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const BannerListener(child: HomeScreen()),
        ),
        // 提词器页面：播放稿件
        // 注意：这个页面使用专门的提词器主题（高对比度）
        GoRoute(
          path: '/teleprompter',
          builder: (context, state) {
            // 读取提词器专用主题
            final theme = ref
                .read(themesProvider)
                .whenOrNull(data: (d) => d.prompterTheme);

            return BannerListener(
              child: Theme(
                // 应用提词器主题，如果主题未加载则使用默认暗色主题
                data: theme ?? ThemeData.dark(),
                child: const PrompterScreen(),
              ),
            );
          },
        ),
        // 打开文件页面：从文件系统加载稿件
        GoRoute(
          path: '/open_file',
          builder: (context, state) =>
              const BannerListener(child: OpenFileScreen()),
        ),
        // 设置页面：应用设置入口
        GoRoute(
          path: '/settings',
          builder: (context, state) =>
              const BannerListener(child: SettingsScreen()),
          // 嵌套子路由：设置的详细页面
          routes: [
            // 显示设置：镜像、指示框、边距等
            GoRoute(
              path: 'display',
              builder: (context, state) =>
                  const BannerListener(child: DisplaySettingsScreen()),
            ),
            // 文本设置：字体、大小、对齐方式等
            GoRoute(
              path: 'text',
              builder: (context, state) =>
                  const BannerListener(child: TextSettingsScreen()),
            ),
          ],
        ),
        // 个人资料页面
        GoRoute(
          path: '/profile',
          builder: (context, state) =>
              const BannerListener(child: ProfileScreen()),
        ),
      ],
    );
  }
}
