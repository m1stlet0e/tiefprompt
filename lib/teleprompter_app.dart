import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promptify/providers/combining_provider.dart';
import 'package:promptify/providers/feature_provider.dart';
import 'package:promptify/providers/router_provider.dart';
import 'package:promptify/providers/settings_provider.dart';
import 'package:promptify/providers/theme_provider.dart';

/// 提词器应用主组件
/// 
/// 这是应用的根 Widget，负责：
/// - 初始化功能特性系统（检查购买状态）
/// - 加载和应用主题
/// - 配置路由
/// - 处理异步加载状态
class TeleprompterApp extends ConsumerStatefulWidget {
  const TeleprompterApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TeleprompterAppState();
}

class _TeleprompterAppState extends ConsumerState<TeleprompterApp> {
  @override
  void initState() {
    // 在第一帧渲染后执行初始化
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 启动功能特性系统
      // 免费增值版：检查是否购买专业版
      // 开源版：直接启用所有功能
      final res = await ref.read(featuresProvider.notifier).bootstrap();

      // 如果初始化失败，重置功能提供者
      if (!res) {
        ref.invalidate(featuresProvider);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 监听主题模式设置（亮色/暗色/系统）
    // 使用 select 只在 themeMode 变化时重建，优化性能
    final themeMode = ref.watch(
      settingsProvider.select((s) => s.whenData((d) => d.themeMode)),
    );
    
    // 监听路由配置
    final router = ref.watch(tiefPromptRouterProvider);
    
    // 监听亮色主题
    final lightTheme = ref.watch(
      themesProvider.select((t) => t.whenData((d) => d.lightTheme)),
    );
    
    // 监听暗色主题
    final darkTheme = ref.watch(
      themesProvider.select((t) => t.whenData((d) => d.darkTheme)),
    );
    
    // 使用组合 Provider 等待所有异步状态加载完成
    // 只有当 themeMode、lightTheme、darkTheme 都加载完成后才构建应用
    final combiningProvider = ref.watch(
      combinedAsyncDataProvider.call([themeMode, lightTheme, darkTheme]),
    );

    // 根据加载状态返回不同的 Widget
    return switch (combiningProvider) {
      // 数据加载完成，构建完整的应用
      AsyncData(:final value) => MaterialApp.router(
        title: 'Teleprompter',
        // 国际化配置
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        // 路由配置
        routerConfig: router,
        // 应用主题（从组合状态中提取）
        theme: value.states[1] as ThemeData,      // 亮色主题
        darkTheme: value.states[2] as ThemeData,  // 暗色主题
        themeMode: value.states[0] as ThemeMode,  // 主题模式
      ),
      
      // 数据加载中，显示基础应用框架（不含主题）
      AsyncLoading() => MaterialApp.router(
        title: 'Teleprompter',
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        routerConfig: router,
      ),
      
      // 加载错误，显示错误提示和重置选项
      _ => Directionality(
        textDirection: TextDirection.ltr, // 强制从左到右（用于错误界面）
        child: Center(
          child: Column(
            children: [
              Text(
                "An exceedingly scary error occurred loading the settings or maybe even the themes ( :c ). Do you want to reset them?",
              ),
              ElevatedButton(
                // 重置设置按钮
                onPressed: () =>
                    ref.read(settingsProvider.notifier).resetSettings(),
                child: Text("Reset Settings"),
              ),
            ],
          ),
        ),
      ),
    };
  }
}
