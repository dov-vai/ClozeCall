import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/config.dart';

class ConfigRepository {
  final Database _db;
  final _tableName = 'config';

  ConfigRepository(this._db);

  Future<void> insert(Config config) async {
    await _db.insert(
      _tableName,
      config.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> get(String key) async {
    final values =
        await _db.query(_tableName, where: 'key = ?', whereArgs: [key]);

    return (values.firstOrNull?['value']) as String?;
  }

  Future<void> update(Config config) async {
    await _db.update(
      _tableName,
      config.toMap(),
      where: 'key = ?',
      whereArgs: [config.key],
    );
  }

  Future<void> delete(String key) async {
    await _db.delete(
      _tableName,
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  Future<List<Config>> entries() async {
    final maps = await _db.query(_tableName);

    return [for (final data in maps) Config.fromMap(data)];
  }
}
