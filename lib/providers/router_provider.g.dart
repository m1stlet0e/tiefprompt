// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$promptifyRouterHash() => r'3332f1f5382bbdb46dde546c60d6cbcaf164d3ef';

/// 路由配置管理器
///
/// 使用 GoRouter 管理应用的所有页面路由
/// - keepAlive: true 保证路由配置在应用生命周期内一直存在
/// - 依赖 Themes Provider，用于为提词器页面应用专用主题
///
/// Copied from [PromptifyRouter].
@ProviderFor(PromptifyRouter)
final promptifyRouterProvider =
    NotifierProvider<PromptifyRouter, GoRouter>.internal(
      PromptifyRouter.new,
      name: r'promptifyRouterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$promptifyRouterHash,
      dependencies: <ProviderOrFamily>[themesProvider],
      allTransitiveDependencies: <ProviderOrFamily>{
        themesProvider,
        ...?themesProvider.allTransitiveDependencies,
      },
    );

typedef _$PromptifyRouter = Notifier<GoRouter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
