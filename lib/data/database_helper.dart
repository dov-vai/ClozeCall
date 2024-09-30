import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    final appDocumentsDir = await getApplicationDocumentsDirectory();
    String dbPath =
        path.join(appDocumentsDir.path, "database", "clozeCallDb.db");

    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      var databaseFactory = databaseFactoryFfi;
      final db = await databaseFactory.openDatabase(dbPath,
          options: OpenDatabaseOptions(version: 1, onCreate: _onCreate));

      return db;
    } else if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      final db = await openDatabase(dbPath, version: 1, onCreate: _onCreate);

      return db;
    }

    throw Exception("No supported platform found when creating database");
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute("""
    CREATE TABLE IF NOT EXISTS config(
      key TEXT PRIMARY KEY,
      value TEXT
    )
    """);
  }
}