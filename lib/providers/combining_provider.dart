import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'combining_provider.freezed.dart';
part 'combining_provider.g.dart';

/// 组合状态数据类
///
/// 将多个异步状态合并为一个状态
@freezed
abstract class CombinedState with _$CombinedState {
  /// 创建组合状态
  ///
  /// [states] - 合并后的状态列表
  factory CombinedState(List<Object> states) = _CombinedState;
}

/// 异步数据组合器
///
/// 用于等待多个异步Provider全部加载完成
/// 
/// **使用场景**：
/// 当一个Widget依赖多个异步Provider时（如主题、设置、路由），
/// 需要等待它们全部加载完成后才能渲染界面
///
/// **状态合并规则**：
/// - 如果有任何一个还在加载中 → 返回 AsyncValue.loading()
/// - 如果有任何一个出错 → 返回第一个错误
/// - 如果全部成功 → 返回合并后的数据
@riverpod
class CombinedAsyncData extends _$CombinedAsyncData {
  /// 构建组合状态
  ///
  /// [states] - 需要组合的异步状态列表
  @override
  AsyncValue<CombinedState> build(List<AsyncValue<Object>> states) {
    // 任何一个还在加载中 → 整体处于加载状态
    if (states.any((state) => state.isLoading)) return AsyncValue.loading();

    // 任何一个出错 → 返回第一个错误
    if (states.any((state) => state.hasError)) {
      return AsyncValue.error(
        states.firstWhere((state) => state.hasError).error!,
        StackTrace.current,
      );
    }

    // 任何一个没有值（异常状态）→ 返回未知错误
    if (states.any((state) => !state.hasValue)) {
      return AsyncValue.error(
        "An unknown and unknowable error may have just occurred, confusing me greatly.",
        StackTrace.current,
      );
    }

    // 全部成功 → 返回组合后的数据
    return AsyncData(
      CombinedState(states.map((state) => state.requireValue).toList()),
    );
  }
}
