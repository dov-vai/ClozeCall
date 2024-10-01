import 'package:cloze_call/data/models/cloze_review.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ClozeReviewRepository {
  final Database _db;
  final _tableName = 'review';

  ClozeReviewRepository(this._db);

  Future<void> insert(ClozeReview cloze) async {
    await _db.insert(
      _tableName,
      cloze.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<ClozeReview?> get(int id) async {
    final values =
        await _db.query(_tableName, where: 'id = ?', whereArgs: [id]);

    final value = values.firstOrNull;

    if (value != null) {
      return ClozeReview.fromMap(value);
    }

    return null;
  }

  Future<void> update(ClozeReview cloze) async {
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

  Future<List<ClozeReview>> entries() async {
    final maps = await _db.query(_tableName);

    return [for (final data in maps) ClozeReview.fromMap(data)];
  }
}
