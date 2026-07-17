import 'package:sqflite/sqflite.dart';

class TomoriDao {
  const TomoriDao(this.db);

  final DatabaseExecutor db;

  Future<int> insert(String table, Map<String, Object?> values) => db.insert(table, values);

  Future<int> updateById(String table, int id, Map<String, Object?> values) {
    return db.update(table, values, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteById(String table, int id) {
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> selectAll(String table, {String? orderBy}) {
    return db.query(table, orderBy: orderBy);
  }

  Future<List<Map<String, Object?>>> selectWhere(
    String table, {
    required String where,
    required List<Object?> whereArgs,
    String? orderBy,
    int? limit,
  }) {
    return db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy, limit: limit);
  }

  Future<int> count(String table) async {
    final rows = await db.rawQuery('SELECT COUNT(*) AS count FROM $table');
    return rows.first['count'] as int;
  }

  Future<int> upsertByWhere(
    String table, {
    required Map<String, Object?> values,
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final rows = await selectWhere(table, where: where, whereArgs: whereArgs, limit: 1);
    if (rows.isEmpty) return insert(table, values);
    final id = rows.first['id'] as int;
    await updateById(table, id, values);
    return id;
  }
}
