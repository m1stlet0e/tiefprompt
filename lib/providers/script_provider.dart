import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 生成的代码文件
part 'script_provider.freezed.dart'; // Freezed 生成的不可变数据类
part 'script_provider.g.dart';       // Riverpod 生成的 Provider 代码

/// 稿件状态数据类
/// 
/// 使用 @freezed 注解生成不可变数据类
/// 自动生成：
/// - copyWith 方法（用于创建修改后的副本）
/// - == 和 hashCode（值比较）
/// - toString（调试输出）
@freezed
abstract class ScriptState with _$ScriptState {
  /// 创建稿件状态
  /// 
  /// [text] - 稿件正文内容
  /// [title] - 稿件标题（可选）
  factory ScriptState({required String text, required String? title}) =
      _ScriptState;
}

/// 稿件状态管理器
/// 
/// 使用 @riverpod 注解生成 Provider
/// 管理当前编辑的稿件内容和标题
@riverpod
class Script extends _$Script {
  /// 初始化状态
  /// 返回空的稿件状态
  @override
  ScriptState build() => ScriptState(text: "", title: null);

  /// 设置稿件文本内容
  /// 
  /// [text] - 新的稿件内容
  void setText(String text) {
    // 使用 copyWith 创建新的状态对象，只修改 text 字段
    state = state.copyWith(text: text);
  }

  /// 设置稿件标题
  /// 
  /// [title] - 新的稿件标题
  void setTitle(String title) {
    // 使用 copyWith 创建新的状态对象，只修改 title 字段
    state = state.copyWith(title: title);
  }
}
