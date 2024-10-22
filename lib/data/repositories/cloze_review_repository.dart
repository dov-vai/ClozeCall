import 'package:cloze_call/data/models/cloze.dart';
import 'package:sqflite/sqflite.dart';

class ClozeReviewRepository {
  final Database _db;
  final _tableName = 'review';

  ClozeReviewRepository(this._db);

  Future<void> insert(Cloze cloze) async {
    await _db.insert(
      _tableName,
      cloze.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<Cloze?> get(int id) async {
    final values =
        await _db.query(_tableName, where: 'id = ?', whereArgs: [id]);

    final value = values.firstOrNull;

    if (value != null) {
      return Cloze.fromMap(value);
    }

    return null;
  }

  Future<void> update(Cloze cloze) async {
    await _db.update(
      _tableName,
      cloze.toMap(),
      where: 'id = ?',
      whereArgs: [cloze.id],
    );
  }

  Future<void> delete(int id) async {
    await _db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Cloze>> entries() async {
    final maps = await _db.query(_tableName);

    return [for (final data in maps) Cloze.fromMap(data)];
  }

  Future<int> count() async {
    return Sqflite.firstIntValue(
            await _db.query(_tableName, columns: ['COUNT(*)'])) ?? 0;
  }
}
