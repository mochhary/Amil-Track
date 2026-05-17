import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteService {
  static const String databaseName = "amil_track.db";
  // FIX: Naik ke versi 3 untuk menambahkan kolom jumlah_jiwa
  static const int databaseVersion = 3;

  static const String tableTransactions = 'local_transactions';

  static const String columnId = 'id';
  static const String columnNamaMuzakki = 'nama_muzakki';
  static const String columnKategoriZakat = 'kategori_zakat';
  static const String columnJumlah = 'jumlah';
  static const String columnTipeSatuan = 'tipe_satuan';
  static const String columnJumlahJiwa = 'jumlah_jiwa'; // KOLOM BARU
  static const String columnCreatedAt = 'created_at';
  static const String columnSyncStatus = 'sync_status';

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
