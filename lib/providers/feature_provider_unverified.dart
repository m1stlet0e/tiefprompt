import 'package:promptify/core/constants.dart';
import 'package:promptify/providers/app_features.dart';
import 'package:promptify/providers/feature_provider.dart';

/// 未验证版功能特性管理器
///
/// 用于开发和调试阶段，所有功能默认开启
/// 在main.dart中被使用（flutter run时的默认入口）
class FeaturesUnverified extends Features {
  /// 初始化功能列表
  ///
  /// 未验证版本提供所有功能，方便开发调试
  @override
  AppFeatures build() {
    return AppFeatures(kAllFeatures, FeatureKind.unverifiedBuild);
  }

  /// 引导初始化
  ///
  /// 未验证版本无需初始化逻辑，直接返回成功
  @override
  Future<bool> bootstrap() {
    // 未验证版本不需要引导逻辑
    return Future.value(true);
  }

  /// 购买专业版
  ///
  /// 未验证版本不支持购买（仅用于开发）
  @override
  Future<void> buyPro() {
    // 未验证版本无购买逻辑
    return Future.value();
  }
}
