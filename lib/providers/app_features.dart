import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tiefprompt/core/constants.dart';

part 'app_features.freezed.dart';

/// 应用功能特性数据类
///
/// 用于区分不同版本（FOSS免费版 / Freemium付费版）可用的功能
@freezed
abstract class AppFeatures with _$AppFeatures {
  /// 创建应用功能特性
  ///
  /// [features] - 当前版本可用的功能列表
  /// [featureKind] - 功能版本类型（FOSS或Freemium）
  factory AppFeatures(List<Feature> features, FeatureKind featureKind) =
      _AppFeatures;
}
