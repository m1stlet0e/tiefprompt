import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:promptify/models/script_model.dart';

// 这个 part 指令告诉 Dart 这个文件的生成代码在 database.g.dart 中
part 'database.g.dart';

/// 应用数据库类
/// 
/// 使用 Drift 管理 SQLite 数据库
/// - 自动处理数据库连接
/// - 类型安全的查询
/// - 自动迁移（根据 schemaVersion）
@DriftDatabase(tables: [ScriptModel]) // 注册所有数据表
class AppDatabase extends _$AppDatabase {
  /// 构造函数，调用 _openConnection 打开数据库连接
  AppDatabase() : super(_openConnection());

  /// 数据库架构版本号
  /// 每次修改表结构时需要增加版本号，Drift 会自动处理迁移
  @override
  int get schemaVersion => 1;

  /// 打开数据库连接
  /// 
  /// 返回：QueryExecutor - 数据库执行器
  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'tiefprompt', // 数据库文件名
      native: const DriftNativeOptions(
        // 数据库文件存储路径（应用支持目录）
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
