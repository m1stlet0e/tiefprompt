// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsHash() => r'6d2bb2b6f04888dad3f380ff1e9690a5c2688baa';

/// 设置管理器
///
/// 负责加载、保存和管理所有用户设置
/// - keepAlive: true 表示这个Provider会一直存在，不会被自动释放
/// - 使用 SharedPreferences 持久化存储
///
/// Copied from [Settings].
@ProviderFor(Settings)
final settingsProvider =
    AsyncNotifierProvider<Settings, SettingsState>.internal(
      Settings.new,
      name: r'settingsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$settingsHash,
      dependencies: const <ProviderOrFamily>[],
      allTransitiveDependencies: const <ProviderOrFamily>{},
    );

typedef _$Settings = AsyncNotifier<SettingsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
