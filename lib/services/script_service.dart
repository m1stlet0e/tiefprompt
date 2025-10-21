import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tiefprompt/models/database.dart';
import 'package:tiefprompt/providers/script_provider.dart';

// 生成的代码文件
part 'script_service.g.dart';

/// 稿件显示数据类
/// 
/// 用于在列表中显示稿件的简化数据
/// 不包含完整的稿件内容，只有列表展示需要的信息
class ScriptDisplayData {
  /// 稿件ID
  final String title;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 主键ID
  final int id;

  /// 构造函数
  ScriptDisplayData({
    required this.id,
    required this.title,
    required this.createdAt,
  });
}

/// 稿件服务类
/// 
/// 封装所有与稿件相关的数据库操作
/// 使用 Drift 的 Manager API 进行类型安全的查询
@riverpod
class ScriptService extends _$ScriptService {
  /// 数据库管理器（Drift 生成的类型安全 API）
  final _databaseManagers = AppDatabase().managers;

  /// 初始化服务（空实现，因为不需要初始状态）
  @override
  Future<void> build() async {}

  /// 获取稿件总数
  /// 
  /// 返回：数据库中保存的稿件数量
  Future<int> getScriptCount() async =>
      await _databaseManagers.scriptModel.count();

  /// 获取所有稿件的实时流
  /// 
  /// 返回：Stream<List<ScriptDisplayData>> - 稿件列表的数据流
  /// 
  /// 当数据库中的稿件发生变化时（增删改），这个流会自动更新
  /// 使用 watch() 实现响应式数据绑定
  Future<Stream<List<ScriptDisplayData>>> getScripts() async =>
      _databaseManagers.scriptModel.asyncMap(_mapToDisplay).watch();

  /// 将数据库记录映射为显示数据
  /// 
  /// [script] - 数据库中的完整稿件记录
  /// 返回：只包含显示所需字段的 ScriptDisplayData
  Future<ScriptDisplayData> _mapToDisplay(ScriptModelData script) async =>
      ScriptDisplayData(
        id: script.id,
        title: script.title,
        createdAt: script.createdAt,
      );

  /// 加载指定稿件的完整内容
  /// 
  /// [scriptId] - 稿件ID
  /// 返回：稿件的文本内容
  Future<String> loadScript(int scriptId) async => await _databaseManagers
      .scriptModel
      .filter((s) => s.id(scriptId))  // WHERE id = scriptId
      .asyncMap(_mapToText)           // 只提取文本字段
      .getSingle();                   // 获取单条记录

  /// 从数据库记录中提取文本内容
  /// 
  /// [script] - 数据库记录
  /// 返回：稿件正文
  Future<String> _mapToText(ScriptModelData script) async => script.scriptText;

  /// 保存稿件到数据库
  /// 
  /// [script] - 要保存的稿件状态
  /// 
  /// 会自动设置创建时间，如果没有标题则使用 "Untitled"
  Future<void> save(ScriptState script) async =>
      await _databaseManagers.scriptModel.create(
        (s) => s(
          scriptText: script.text,
          title: script.title ?? "Untitled",  // 如果标题为空，使用默认值
          createdAt: DateTime.now(),           // 当前时间
        ),
      );

  /// 删除指定的稿件
  /// 
  /// [scriptId] - 要删除的稿件ID
  Future<void> deleteScript(int scriptId) async => await _databaseManagers
      .scriptModel
      .filter((s) => s.id(scriptId))  // WHERE id = scriptId
      .delete();                      // 执行删除
}
