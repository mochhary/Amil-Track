import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'sqlite_schema.dart';

class SqliteService {
  static const String databaseName = "amil_track.db";
  // FIX: Naik ke versi 5 untuk multi-tenancy (tambah kolom user_id)
  static const int databaseVersion = 5;

  // Schema identifiers are exposed through a single abstraction gateway.
  static String get tableTransactions => SqliteSchema.transactionsTable;

  static String get columnId => SqliteSchema.id;
  static String get columnNamaMuzakki => SqliteSchema.namaMuzakki;
  static String get columnKategoriZakat => SqliteSchema.kategoriZakat;
  static String get columnJumlah => SqliteSchema.jumlah;
  static String get columnTipeSatuan => SqliteSchema.tipeSatuan;
  static String get columnJumlahJiwa => SqliteSchema.jumlahJiwa;
  static String get columnNomorWhatsapp => SqliteSchema.nomorWhatsapp;
  static String get columnUserId => SqliteSchema.userId;
  static String get columnCreatedAt => SqliteSchema.createdAt;
  static String get columnSyncStatus => SqliteSchema.syncStatus;

  SqliteService._privateConstructor();
  static final SqliteService instance = SqliteService._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), databaseName);
    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTransactions (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnNamaMuzakki TEXT NOT NULL,
        $columnKategoriZakat TEXT NOT NULL,
        $columnJumlah REAL NOT NULL,
        $columnTipeSatuan TEXT NOT NULL,
        $columnJumlahJiwa INTEGER, 
        $columnNomorWhatsapp TEXT,
        $columnUserId TEXT,
        $columnCreatedAt TEXT NOT NULL,
        $columnSyncStatus INTEGER DEFAULT 0
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Upgrading to version 3 (added jumlah_jiwa) - fallback to drop table for old versions
      await db.execute('DROP TABLE IF EXISTS $tableTransactions');
      await _onCreate(db, newVersion);
    } else {
      if (oldVersion < 4) {
        // Safe migration for version 4 (added nomor_whatsapp)
        await db.execute('ALTER TABLE $tableTransactions ADD COLUMN $columnNomorWhatsapp TEXT');
      }
      if (oldVersion < 5) {
        // Safe migration for version 5 (added user_id)
        await db.execute('ALTER TABLE $tableTransactions ADD COLUMN $columnUserId TEXT');
      }
    }
  }
}
