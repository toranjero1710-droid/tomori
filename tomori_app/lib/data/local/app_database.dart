import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  Database? _database;

  Future<Database> open() async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is available on Android and iOS builds.');
    }
    if (_database != null) return _database!;

    final path = join(await getDatabasesPath(), 'tomori_app.db');
    _database = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _ensureSprint6Schema(db);
      },
    );
    await _ensureSprint6Schema(_database!);
    return _database!;
  }

  Future<void> seedSprint6TestData() async {
    if (kIsWeb) return;
    final db = await open();
    await db.transaction((txn) async {
      final customerId = await _upsertCustomer(txn);
      final plannedVisitId = await _upsertVisit(
        txn,
        customerId: customerId,
        scheduledAt: '2026-07-25 10:00',
        status: 'planned',
      );
      final completedVisitId = await _upsertVisit(
        txn,
        customerId: customerId,
        scheduledAt: '2026-07-18',
        status: 'completed',
        weather: '晴れ',
        actions: '外観確認, ポスト確認, 換気, 通水, 玄関前の簡単な掃き掃除, 庭の草を少し整える, 施錠確認',
        voiceMemo: testVoiceMemo,
      );
      await _upsertFiveTalks(txn, customerId);
      await _upsertHouseNote(txn, customerId);
      await _upsertPhotos(txn, completedVisitId);
      await _upsertTomoriLetter(txn, completedVisitId);
      await _upsertAnnualLetter(txn, customerId);
      await _upsertMemo(txn, customerId);
      await _upsertVisit(
        txn,
        customerId: customerId,
        scheduledAt: '2026-07-25 10:00',
        status: 'planned',
        id: plannedVisitId,
      );
    });
  }

  Future<Map<String, dynamic>?> loadSprint6Snapshot() async {
    if (kIsWeb) return null;
    final db = await open();
    final customers = await db.query('Customer', where: 'name = ?', whereArgs: ['山田テスト様'], limit: 1);
    if (customers.isEmpty) return null;
    final customer = customers.first;
    final customerId = customer['id'] as int;
    final plannedVisits = await db.query('Visit', where: 'customerId = ? AND status = ?', whereArgs: [customerId, 'planned'], limit: 1);
    final completedVisits = await db.query('Visit', where: 'customerId = ? AND status = ?', whereArgs: [customerId, 'completed'], limit: 1);
    final visitId = completedVisits.isEmpty ? null : completedVisits.first['id'] as int;
    final photos = visitId == null ? <Map<String, Object?>>[] : await db.query('Photo', where: 'visitId = ?', whereArgs: [visitId], orderBy: 'id ASC');
    final letters = visitId == null ? <Map<String, Object?>>[] : await db.query('TomoriLetter', where: 'visitId = ?', whereArgs: [visitId], limit: 1);
    final talks = await db.query('FiveTalk', where: 'customerId = ?', whereArgs: [customerId], orderBy: 'questionNumber ASC');
    final notes = await db.query('HouseNote', where: 'customerId = ?', whereArgs: [customerId], limit: 1);
    final annual = await db.query('AnnualLetter', where: 'customerId = ? AND year = ?', whereArgs: [customerId, 2026], limit: 1);
    return {
      'customer': customer,
      'plannedVisit': plannedVisits.isEmpty ? null : plannedVisits.first,
      'completedVisit': completedVisits.isEmpty ? null : completedVisits.first,
      'photos': photos,
      'letter': letters.isEmpty ? null : letters.first,
      'fiveTalks': talks,
      'houseNote': notes.isEmpty ? null : notes.first,
      'annual': annual.isEmpty ? null : annual.first,
    };
  }

  Future<void> saveManualLetterNote(String note) async {
    if (kIsWeb) return;
    final db = await open();
    final rows = await db.rawQuery('''
      SELECT TomoriLetter.id AS id
      FROM TomoriLetter
      INNER JOIN Visit ON Visit.id = TomoriLetter.visitId
      INNER JOIN Customer ON Customer.id = Visit.customerId
      WHERE Customer.name = ? AND Visit.scheduledAt = ?
      LIMIT 1
    ''', ['山田テスト様', '2026-07-18']);
    if (rows.isNotEmpty) {
      await db.update('TomoriLetter', {'note': note}, where: 'id = ?', whereArgs: [rows.first['id']]);
    }
  }

  Future<void> _createTables(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE Customer (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        displayName TEXT,
        address TEXT NOT NULL,
        plan TEXT NOT NULL,
        phone TEXT,
        lineId TEXT,
        keyNumber TEXT,
        emergencyContact TEXT,
        emergencyPhone TEXT,
        imagePath TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE Visit (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId INTEGER NOT NULL,
        scheduledAt TEXT NOT NULL,
        status TEXT NOT NULL,
        weather TEXT,
        actions TEXT,
        voiceMemo TEXT,
        FOREIGN KEY(customerId) REFERENCES Customer(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE Photo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visitId INTEGER NOT NULL,
        guideName TEXT NOT NULL,
        imagePath TEXT,
        captured INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(visitId) REFERENCES Visit(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE TomoriLetter (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visitId INTEGER NOT NULL,
        draftText TEXT NOT NULL,
        note TEXT,
        sentAt TEXT,
        FOREIGN KEY(visitId) REFERENCES Visit(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE AnnualLetter (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId INTEGER NOT NULL,
        year INTEGER NOT NULL,
        springImage TEXT,
        summerImage TEXT,
        autumnImage TEXT,
        winterImage TEXT,
        pdfPath TEXT,
        recordSummary TEXT,
        FOREIGN KEY(customerId) REFERENCES Customer(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE Memo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId INTEGER NOT NULL,
        body TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY(customerId) REFERENCES Customer(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE FiveTalk (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId INTEGER NOT NULL,
        questionNumber INTEGER NOT NULL,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        FOREIGN KEY(customerId) REFERENCES Customer(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE HouseNote (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId INTEGER NOT NULL,
        importantThings TEXT NOT NULL,
        nextChecks TEXT NOT NULL,
        tomoriMemo TEXT NOT NULL,
        FOREIGN KEY(customerId) REFERENCES Customer(id)
      )
    ''');
  }

  Future<void> _ensureSprint6Schema(Database db) async {
    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    final names = tables.map((row) => row['name']).whereType<String>().toSet();
    if (!names.contains('Customer')) {
      await _createTables(db);
      return;
    }
    await _addColumnIfMissing(db, 'Customer', 'displayName', 'TEXT');
    await _addColumnIfMissing(db, 'Customer', 'keyNumber', 'TEXT');
    await _addColumnIfMissing(db, 'Customer', 'emergencyContact', 'TEXT');
    await _addColumnIfMissing(db, 'Customer', 'emergencyPhone', 'TEXT');
    await _addColumnIfMissing(db, 'Visit', 'weather', 'TEXT');
    await _addColumnIfMissing(db, 'Visit', 'actions', 'TEXT');
    await _addColumnIfMissing(db, 'Visit', 'voiceMemo', 'TEXT');
    await _addColumnIfMissing(db, 'AnnualLetter', 'recordSummary', 'TEXT');
    if (!names.contains('FiveTalk')) {
      await db.execute('''
        CREATE TABLE FiveTalk (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          customerId INTEGER NOT NULL,
          questionNumber INTEGER NOT NULL,
          question TEXT NOT NULL,
          answer TEXT NOT NULL,
          FOREIGN KEY(customerId) REFERENCES Customer(id)
        )
      ''');
    }
    if (!names.contains('HouseNote')) {
      await db.execute('''
        CREATE TABLE HouseNote (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          customerId INTEGER NOT NULL,
          importantThings TEXT NOT NULL,
          nextChecks TEXT NOT NULL,
          tomoriMemo TEXT NOT NULL,
          FOREIGN KEY(customerId) REFERENCES Customer(id)
        )
      ''');
    }
  }

  Future<void> _addColumnIfMissing(Database db, String table, String column, String type) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((row) => row['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    }
  }

  Future<int> _upsertCustomer(Transaction txn) async {
    final rows = await txn.query('Customer', where: 'name = ?', whereArgs: ['山田テスト様'], limit: 1);
    final values = {
      'name': '山田テスト様',
      'displayName': '山田様のお家',
      'address': '大阪府高槻市テスト町1-2-3',
      'plan': '基本プラン',
      'phone': '090-0000-0000',
      'lineId': '未設定',
      'keyNumber': 'TEST-001',
      'emergencyContact': '山田花子',
      'emergencyPhone': '090-1111-1111',
      'imagePath': homeImage,
    };
    if (rows.isEmpty) return txn.insert('Customer', values);
    final id = rows.first['id'] as int;
    await txn.update('Customer', values, where: 'id = ?', whereArgs: [id]);
    return id;
  }

  Future<int> _upsertVisit(
    Transaction txn, {
    required int customerId,
    required String scheduledAt,
    required String status,
    String? weather,
    String? actions,
    String? voiceMemo,
    int? id,
  }) async {
    if (id != null) return id;
    final rows = await txn.query('Visit', where: 'customerId = ? AND scheduledAt = ? AND status = ?', whereArgs: [customerId, scheduledAt, status], limit: 1);
    final values = {
      'customerId': customerId,
      'scheduledAt': scheduledAt,
      'status': status,
      'weather': weather,
      'actions': actions,
      'voiceMemo': voiceMemo,
    };
    if (rows.isEmpty) return txn.insert('Visit', values);
    final visitId = rows.first['id'] as int;
    await txn.update('Visit', values, where: 'id = ?', whereArgs: [visitId]);
    return visitId;
  }

  Future<void> _upsertFiveTalks(Transaction txn, int customerId) async {
    final talks = [
      ['今、一番気になっていること', '台風や大雨の後のお家の状態が心配。'],
      ['このお家で大切にされていること', '庭の紫陽花と、お父様が植えた松。'],
      ['今はどなたが見守られているか', '長女の山田花子様。'],
      ['お家までどれくらい離れているか', '東京から大阪のため、すぐには帰れない。'],
      ['これから、このお家をどうしていきたいか', '今すぐ売却せず、しばらく家族の思い出として残したい。'],
    ];
    for (var i = 0; i < talks.length; i++) {
      final rows = await txn.query('FiveTalk', where: 'customerId = ? AND questionNumber = ?', whereArgs: [customerId, i + 1], limit: 1);
      final values = {'customerId': customerId, 'questionNumber': i + 1, 'question': talks[i][0], 'answer': talks[i][1]};
      if (rows.isEmpty) {
        await txn.insert('FiveTalk', values);
      } else {
        await txn.update('FiveTalk', values, where: 'id = ?', whereArgs: [rows.first['id']]);
      }
    }
  }

  Future<void> _upsertHouseNote(Transaction txn, int customerId) async {
    final values = {
      'customerId': customerId,
      'importantThings': '庭の紫陽花\nお父様が植えた松\n仏壇\n玄関前をきれいに保つこと',
      'nextChecks': '松の状態\nポスト\n紫陽花\n雨どい\n玄関まわり',
      'tomoriMemo': '紫陽花の写真を毎回楽しみにされている\n年末に帰省予定\n勝手な修理や処分は絶対に行わない\n気になる点は写真付きで事前相談する',
    };
    final rows = await txn.query('HouseNote', where: 'customerId = ?', whereArgs: [customerId], limit: 1);
    if (rows.isEmpty) {
      await txn.insert('HouseNote', values);
    } else {
      await txn.update('HouseNote', values, where: 'id = ?', whereArgs: [rows.first['id']]);
    }
  }

  Future<void> _upsertPhotos(Transaction txn, int visitId) async {
    final photos = [
      ['家全体', homeImage],
      ['玄関', homeImage],
      ['庭', 'assets/images/services/care.webp'],
      ['室内', 'assets/images/services/home-watch.webp'],
      ['気になった場所', 'assets/images/services/photo-seven.webp'],
      ['季節の一枚', 'assets/images/services/tomori-letter.webp'],
      ['巡回終了後のお家', 'assets/images/services/annual-letter.webp'],
    ];
    for (final photo in photos) {
      final rows = await txn.query('Photo', where: 'visitId = ? AND guideName = ?', whereArgs: [visitId, photo[0]], limit: 1);
      final values = {'visitId': visitId, 'guideName': photo[0], 'imagePath': photo[1], 'captured': 1};
      if (rows.isEmpty) {
        await txn.insert('Photo', values);
      } else {
        await txn.update('Photo', values, where: 'id = ?', whereArgs: [rows.first['id']]);
      }
    }
  }

  Future<void> _upsertTomoriLetter(Transaction txn, int visitId) async {
    final values = {
      'visitId': visitId,
      'draftText': testAiDraft,
      'note': '紫陽花の写真を添えてお送りします。',
      'sentAt': '2026-07-18 11:00',
    };
    final rows = await txn.query('TomoriLetter', where: 'visitId = ?', whereArgs: [visitId], limit: 1);
    if (rows.isEmpty) {
      await txn.insert('TomoriLetter', values);
    } else {
      await txn.update('TomoriLetter', values, where: 'id = ?', whereArgs: [rows.first['id']]);
    }
  }

  Future<void> _upsertAnnualLetter(Transaction txn, int customerId) async {
    final values = {
      'customerId': customerId,
      'year': 2026,
      'springImage': 'assets/images/annual-letter/season-album.webp',
      'summerImage': homeImage,
      'autumnImage': 'assets/images/services/annual-letter.webp',
      'winterImage': 'assets/images/services/tomori-letter.webp',
      'recordSummary': '2026-07-18 晴れ: 玄関前の掃き掃除、紫陽花、松、換気・通水、施錠確認を記録。',
    };
    final rows = await txn.query('AnnualLetter', where: 'customerId = ? AND year = ?', whereArgs: [customerId, 2026], limit: 1);
    if (rows.isEmpty) {
      await txn.insert('AnnualLetter', values);
    } else {
      await txn.update('AnnualLetter', values, where: 'id = ?', whereArgs: [rows.first['id']]);
    }
  }

  Future<void> _upsertMemo(Transaction txn, int customerId) async {
    final rows = await txn.query('Memo', where: 'customerId = ? AND createdAt = ?', whereArgs: [customerId, '2026-07-18'], limit: 1);
    final values = {'customerId': customerId, 'body': testVoiceMemo, 'createdAt': '2026-07-18'};
    if (rows.isEmpty) {
      await txn.insert('Memo', values);
    } else {
      await txn.update('Memo', values, where: 'id = ?', whereArgs: [rows.first['id']]);
    }
  }
}

const homeImage = 'assets/images/hero/tomori-hero-home.png';

const testVoiceMemo = '玄関前を掃きました。\n庭の紫陽花がきれいに咲いていました。\n郵便物はチラシが2通ありました。\n換気と通水を行いました。\n雨漏りや窓ガラスの破損は見当たりませんでした。\n松も元気そうでした。\n最後に窓と玄関の施錠を確認しました。';

const testAiDraft = '今日も、お家へ会いに行ってきました。\n\n玄関前を掃き、庭の紫陽花がきれいに咲いていることを確認しました。郵便物はチラシが2通ありました。\n\n換気と通水を行い、雨漏りや窓ガラスの破損は見当たりませんでした。お父様が植えられた松も元気そうでした。\n\n最後に窓と玄関の施錠を確認しています。\n\n今日も、お家は変わらず元気でした。';
