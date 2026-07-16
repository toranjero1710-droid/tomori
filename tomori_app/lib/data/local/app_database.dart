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
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Customer (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            address TEXT NOT NULL,
            plan TEXT NOT NULL,
            phone TEXT,
            lineId TEXT,
            imagePath TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE Visit (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customerId INTEGER NOT NULL,
            scheduledAt TEXT NOT NULL,
            status TEXT NOT NULL,
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
      },
    );
    return _database!;
  }
}
