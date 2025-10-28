import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promptify/core/constants.dart';
import 'package:promptify/providers/feature_provider.dart';
import 'package:promptify/providers/feature_provider_unverified.dart';
import 'package:promptify/teleprompter_app.dart';

// ==================== 主入口文件 ====================
// 
// 这是开发时使用的默认入口点
// 注意：构建生产版本时应使用：
//   - main_foss.dart（开源免费版）
//   - main_freemium.dart（免费增值版）
//
// 可以使用 flutter run -t lib/main_foss.dart 来运行特定入口

/// 应用主函数
/// 
/// 执行流程：
/// 1. 初始化 Flutter 框架
/// 2. 配置系统 UI 样式
/// 3. 初始化国际化
/// 4. 启动应用
void main() async {
  // 确保 Flutter 框架已初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置系统UI样式
  // - 导航栏和状态栏设置为透明
  // - 启用沉浸式全屏体验
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent, // 导航栏透明
      statusBarColor: Colors.transparent,           // 状态栏透明
    ),
  );
  
  // 启用边到边显示模式（内容可以延伸到系统栏下方）
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  // 初始化国际化系统
  await el.EasyLocalization.ensureInitialized();

  // 启动应用
  runApp(
    // Riverpod 的根容器
    ProviderScope(
      // 覆盖功能特性 Provider 为未验证构建版本
      // 未验证构建：所有功能可用，但会显示警告提示
      overrides: [featuresProvider.overrideWith(() => FeaturesUnverified())],
      child: el.EasyLocalization(
        // 从常量中获取支持的语言列表
        supportedLocales: kSupportedLocales.map((l10n) => l10n.$2).toList(),
        // 翻译文件路径
        path: 'assets/translations',
        // 默认回退语言（英语）
        fallbackLocale: Locale('en', 'US'),
        // 启用回退翻译（如果某个翻译缺失，使用英语）
        useFallbackTranslations: true,
        // 应用主组件
        child: TeleprompterApp(),
      ),
    ),
  );
}
