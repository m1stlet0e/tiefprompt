// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tiefPromptRouterHash() => r'53152d3d937ec19adda5ea5ddc8f3479d883f632';

/// 路由配置管理器
///
/// 使用 GoRouter 管理应用的所有页面路由
/// - keepAlive: true 保证路由配置在应用生命周期内一直存在
/// - 依赖 Themes Provider，用于为提词器页面应用专用主题
///
/// Copied from [TiefPromptRouter].
@ProviderFor(TiefPromptRouter)
final tiefPromptRouterProvider =
    NotifierProvider<TiefPromptRouter, GoRouter>.internal(
      TiefPromptRouter.new,
      name: r'tiefPromptRouterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$tiefPromptRouterHash,
      dependencies: <ProviderOrFamily>[themesProvider],
      allTransitiveDependencies: <ProviderOrFamily>{
        themesProvider,
        ...?themesProvider.allTransitiveDependencies,
      },
    );

typedef _$TiefPromptRouter = Notifier<GoRouter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
