import 'package:drift/drift.dart';

/// 稿件数据模型表定义
/// 
/// 使用 Drift ORM 定义数据库表结构
/// Drift 会自动生成对应的：
/// - ScriptModelData 类（数据实体）
/// - ScriptModelCompanion 类（用于插入/更新）
/// - 各种查询方法
class ScriptModel extends Table {
  /// 主键 ID，自动递增
  IntColumn get id => integer().autoIncrement()();
  
  /// 稿件标题
  TextColumn get title => text()();
  
  /// 稿件正文内容
  TextColumn get scriptText => text()();
  
  /// 创建时间
  DateTimeColumn get createdAt => dateTime()();
}
