import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiefprompt/core/constants.dart';
import 'package:tiefprompt/providers/feature_provider.dart';
import 'package:tiefprompt/providers/feature_provider_foss.dart';
import 'package:tiefprompt/teleprompter_app.dart';

// ==================== FOSS版主入口文件 ====================
//
// 这是FOSS（Free and Open Source Software）版本的入口点
// 用于 F-Droid 和自行构建的完全免费版本
//
// **与其他版本的区别**：
// - main.dart: 开发版（未验证构建）
// - main_foss.dart: FOSS免费版（所有功能默认解锁）← 本文件
// - main_freemium.dart: Freemium付费版（基础功能免费，高级功能需购买）
//
// **构建方式**：
// flutter build apk -t lib/main_foss.dart
// flutter build ios -t lib/main_foss.dart

/// FOSS版应用主函数
///
/// 初始化步骤：
/// 1. 确保Flutter框架初始化
/// 2. 配置系统UI样式（透明状态栏、导航栏）
/// 3. 启用边到边显示模式
/// 4. 初始化国际化
/// 5. 启动应用，使用 FeaturesFoss 提供所有功能
void main() async {
  // 确保Flutter框架已初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置系统UI样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,  // 导航栏透明
      statusBarColor: Colors.transparent,            // 状态栏透明
    ),
  );
  // 启用边到边显示模式（沉浸式体验）
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  // 初始化EasyLocalization国际化系统
  await el.EasyLocalization.ensureInitialized();

  // 启动应用
  runApp(
    ProviderScope(
      // 覆盖featuresProvider，使用FOSS版功能管理器
      // FeaturesFoss会解锁所有功能，无需购买
      overrides: [featuresProvider.overrideWith(() => FeaturesFoss())],
      child: el.EasyLocalization(
        supportedLocales: kSupportedLocales.map((l10n) => l10n.$2).toList(),
        path: 'assets/translations',
        fallbackLocale: Locale('en', 'US'),
        useFallbackTranslations: true,
        child: TeleprompterApp(),
      ),
    ),
  );
}
