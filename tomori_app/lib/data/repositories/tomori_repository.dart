import '../local/app_database.dart';
import '../local/tomori_dao.dart';

class TomoriRepository {
  Future<TomoriDao> _dao() async {
    final db = await AppDatabase.instance.open();
    return TomoriDao(db);
  }

  Future<int> saveCustomer(Map<String, Object?> values) async {
    final dao = await _dao();
    return dao.upsertByWhere('Customer', values: values, where: 'name = ?', whereArgs: [values['name']]);
  }

  Future<int> saveVisit(Map<String, Object?> values) async {
    final dao = await _dao();
    return dao.upsertByWhere(
      'Visit',
      values: values,
      where: 'customerId = ? AND scheduledAt = ? AND status = ?',
      whereArgs: [values['customerId'], values['scheduledAt'], values['status']],
    );
  }

  Future<int> savePhoto(Map<String, Object?> values) async {
    final dao = await _dao();
    return dao.upsertByWhere(
      'Photo',
      values: values,
      where: 'visitId = ? AND guideName = ?',
      whereArgs: [values['visitId'], values['guideName']],
    );
  }

  Future<int> saveFiveTalk(Map<String, Object?> values) async {
    final dao = await _dao();
    return dao.upsertByWhere(
      'FiveTalk',
      values: values,
      where: 'customerId = ? AND questionNumber = ?',
      whereArgs: [values['customerId'], values['questionNumber']],
    );
  }

  Future<int> saveHouseNote(Map<String, Object?> values) async {
    final dao = await _dao();
    return dao.upsertByWhere('HouseNote', values: values, where: 'customerId = ?', whereArgs: [values['customerId']]);
  }

  Future<int> saveTomoriLetter(Map<String, Object?> values) async {
    final dao = await _dao();
    return dao.upsertByWhere('TomoriLetter', values: values, where: 'visitId = ?', whereArgs: [values['visitId']]);
  }

  Future<int> saveAnnualLetter(Map<String, Object?> values) async {
    final dao = await _dao();
    return dao.upsertByWhere(
      'AnnualLetter',
      values: values,
      where: 'customerId = ? AND year = ?',
      whereArgs: [values['customerId'], values['year']],
    );
  }

  Future<int> saveMemo(Map<String, Object?> values) async {
    final dao = await _dao();
    return dao.upsertByWhere(
      'Memo',
      values: values,
      where: 'customerId = ? AND createdAt = ?',
      whereArgs: [values['customerId'], values['createdAt']],
    );
  }

  Future<Map<String, dynamic>?> loadYamadaSnapshot() async {
    final dao = await _dao();
    final customers = await dao.selectWhere('Customer', where: 'name = ?', whereArgs: ['山田テスト様'], limit: 1);
    if (customers.isEmpty) return null;
    final customer = customers.first;
    final customerId = customer['id'] as int;
    final visits = await dao.selectWhere('Visit', where: 'customerId = ?', whereArgs: [customerId], orderBy: 'scheduledAt DESC', limit: 1);
    final visitId = visits.isEmpty ? null : visits.first['id'] as int;
    final letters = visitId == null ? <Map<String, Object?>>[] : await dao.selectWhere('TomoriLetter', where: 'visitId = ?', whereArgs: [visitId], limit: 1);
    final talks = await dao.selectWhere('FiveTalk', where: 'customerId = ?', whereArgs: [customerId], orderBy: 'questionNumber ASC', limit: 1);
    final notes = await dao.selectWhere('HouseNote', where: 'customerId = ?', whereArgs: [customerId], limit: 1);
    final annual = await dao.selectWhere('AnnualLetter', where: 'customerId = ? AND year = ?', whereArgs: [customerId, 2026], limit: 1);
    final memo = await dao.selectWhere('Memo', where: 'customerId = ?', whereArgs: [customerId], orderBy: 'createdAt DESC', limit: 1);
    return {
      'customer': customer,
      'visit': visits.isEmpty ? null : visits.first,
      'photos': visitId == null ? <Map<String, Object?>>[] : await dao.selectWhere('Photo', where: 'visitId = ?', whereArgs: [visitId], orderBy: 'id ASC'),
      'letter': letters.isEmpty ? null : letters.first,
      'fiveTalk': talks.isEmpty ? null : talks.first,
      'houseNote': notes.isEmpty ? null : notes.first,
      'annual': annual.isEmpty ? null : annual.first,
      'memo': memo.isEmpty ? null : memo.first,
    };
  }

  Future<Map<String, int>> counts() async {
    final dao = await _dao();
    final result = <String, int>{};
    for (final table in ['Customer', 'Visit', 'Photo', 'FiveTalk', 'HouseNote', 'TomoriLetter', 'AnnualLetter', 'Memo']) {
      result[table] = await dao.count(table);
    }
    return result;
  }

  Future<int> deleteById(String table, int id) async {
    final dao = await _dao();
    return dao.deleteById(table, id);
  }
}
