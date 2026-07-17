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

    late final String path;
    try {
      path = join(await getDatabasesPath(), 'tomori_app.db');
      _database = await openDatabase(
        path,
        version: 3,
        onCreate: (db, version) async => _createTables(db),
        onUpgrade: (db, oldVersion, newVersion) async => _ensureSchema(db),
      );
    } catch (_) {
      throw UnsupportedError('SQLite is not available in this runtime.');
    }
    await _ensureSchema(_database!);
    return _database!;
  }

  Future<void> _createTables(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Customer (
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
        imagePath TEXT,
        nextVisit TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Visit (
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
      CREATE TABLE IF NOT EXISTS Photo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visitId INTEGER NOT NULL,
        guideName TEXT NOT NULL,
        imagePath TEXT,
        captured INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(visitId) REFERENCES Visit(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS TomoriLetter (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visitId INTEGER NOT NULL,
        draftText TEXT NOT NULL,
        note TEXT,
        sentAt TEXT,
        FOREIGN KEY(visitId) REFERENCES Visit(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS AnnualLetter (
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
      CREATE TABLE IF NOT EXISTS FiveTalk (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId INTEGER NOT NULL,
        questionNumber INTEGER NOT NULL,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        FOREIGN KEY(customerId) REFERENCES Customer(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS HouseNote (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId INTEGER NOT NULL,
        importantThings TEXT NOT NULL,
        nextChecks TEXT NOT NULL,
        tomoriMemo TEXT NOT NULL,
        FOREIGN KEY(customerId) REFERENCES Customer(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Memo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId INTEGER NOT NULL,
        body TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY(customerId) REFERENCES Customer(id)
      )
    ''');
  }

  Future<void> _ensureSchema(Database db) async {
    await _createTables(db);
    await _addColumnIfMissing(db, 'Customer', 'displayName', 'TEXT');
    await _addColumnIfMissing(db, 'Customer', 'keyNumber', 'TEXT');
    await _addColumnIfMissing(db, 'Customer', 'emergencyContact', 'TEXT');
    await _addColumnIfMissing(db, 'Customer', 'emergencyPhone', 'TEXT');
    await _addColumnIfMissing(db, 'Customer', 'nextVisit', 'TEXT');
    await _addColumnIfMissing(db, 'Visit', 'weather', 'TEXT');
    await _addColumnIfMissing(db, 'Visit', 'actions', 'TEXT');
    await _addColumnIfMissing(db, 'Visit', 'voiceMemo', 'TEXT');
    await _addColumnIfMissing(db, 'AnnualLetter', 'recordSummary', 'TEXT');
  }

  Future<void> _addColumnIfMissing(Database db, String table, String column, String type) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((row) => row['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    }
  }
}
