import 'package:promptify/core/constants.dart';
import 'package:promptify/providers/app_features.dart';
import 'package:promptify/providers/feature_provider.dart';

/// FOSS版功能特性管理器
///
/// 完全免费的开源版本，所有功能默认解锁
/// 用于 F-Droid 和自行构建的版本
class FeaturesFoss extends Features {
  /// 初始化功能列表
  ///
  /// FOSS版本提供所有功能，无任何限制
  @override
  AppFeatures build() {
    return AppFeatures(kAllFeatures, FeatureKind.fossVersion);
  }

  /// 引导初始化
  ///
  /// FOSS版本无需初始化逻辑，直接返回成功
  @override
  Future<bool> bootstrap() {
    // FOSS版本不需要引导逻辑
    return Future.value(true);
  }

  /// 购买专业版
  ///
  /// FOSS版本不支持购买，所有功能已免费提供
  @override
  Future<void> buyPro() {
    // FOSS版本无购买逻辑
    return Future.value();
  }
}
