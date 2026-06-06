import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'sqlite_schema.dart';

class SqliteService {
  static const String databaseName = "amil_track.db";
  // FIX: Naik ke versi 3 untuk menambahkan kolom jumlah_jiwa
  static const int databaseVersion = 3;

  // Schema identifiers are exposed through a single abstraction gateway.
  static String get tableTransactions => SqliteSchema.transactionsTable;

  static String get columnId => SqliteSchema.id;
  static String get columnNamaMuzakki => SqliteSchema.namaMuzakki;
  static String get columnKategoriZakat => SqliteSchema.kategoriZakat;
  static String get columnJumlah => SqliteSchema.jumlah;
  static String get columnTipeSatuan => SqliteSchema.tipeSatuan;
  static String get columnJumlahJiwa => SqliteSchema.jumlahJiwa;
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
        $columnCreatedAt TEXT NOT NULL,
        $columnSyncStatus INTEGER DEFAULT 0
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS $tableTransactions');
    await _onCreate(db, newVersion);
  }
}
