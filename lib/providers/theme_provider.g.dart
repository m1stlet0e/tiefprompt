// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$themesHash() => r'2b2057a7d63c98f454e3e1ec7480cc390ee3f987';

/// 主题管理器
///
/// 根据用户设置的颜色动态生成应用主题
/// - 依赖 Settings Provider，当颜色设置变化时自动重新构建
/// - keepAlive: true 保证主题始终在内存中
///
/// Copied from [Themes].
@ProviderFor(Themes)
final themesProvider = AsyncNotifierProvider<Themes, ThemesState>.internal(
  Themes.new,
  name: r'themesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$themesHash,
  dependencies: <ProviderOrFamily>[settingsProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    settingsProvider,
    ...?settingsProvider.allTransitiveDependencies,
  },
);

typedef _$Themes = AsyncNotifier<ThemesState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
