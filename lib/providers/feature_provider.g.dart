// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$featuresHash() => r'b2bedd4ebf3bfbcae2b01dffe957b51cd3935aae';

/// 功能特性管理器（基类）
///
/// 这是一个抽象类，定义了功能管理的接口
/// 实际实现由以下子类提供：
/// - FeaturesUnverified: 未验证构建（开发时使用）
/// - FeaturesFoss: FOSS免费版
/// - FeaturesFreemium: Freemium付费版
///
/// Copied from [Features].
@ProviderFor(Features)
final featuresProvider =
    AutoDisposeNotifierProvider<Features, AppFeatures>.internal(
      Features.new,
      name: r'featuresProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$featuresHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Features = AutoDisposeNotifier<AppFeatures>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
