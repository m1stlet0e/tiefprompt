import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tiefprompt/core/constants.dart';
import 'package:tiefprompt/providers/app_features.dart';

part 'feature_provider.g.dart';

/// 功能特性管理器（基类）
///
/// 这是一个抽象类，定义了功能管理的接口
/// 实际实现由以下子类提供：
/// - FeaturesUnverified: 未验证构建（开发时使用）
/// - FeaturesFoss: FOSS免费版
/// - FeaturesFreemium: Freemium付费版
@riverpod
class Features extends _$Features {
  /// 初始化功能列表
  ///
  /// 默认返回空功能列表和未验证状态
  @override
  AppFeatures build() {
    return AppFeatures([], FeatureKind.unverifiedBuild);
  }

  /// 引导初始化功能特性
  ///
  /// 这个方法由子类实现，用于：
  /// - FOSS版：直接返回所有功能
  /// - Freemium版：检查购买状态，决定可用功能
  ///
  /// 返回：是否初始化成功
  Future<bool> bootstrap() {
    throw UnimplementedError('bootstrap must be implemented in subclasses');
  }

  /// 购买专业版
  ///
  /// 仅在Freemium版本中有实现，用于触发应用内购买流程
  Future<void> buyPro() {
    throw UnimplementedError('buyPro must be implemented in subclasses');
  }
}
