import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class SqliteService {
  // Pattern Singleton agar koneksi database hanya dibuka 1 kali
  SqliteService._privateConstructor();
  static final SqliteService instance = SqliteService._privateConstructor();

  static Database? _database;

  // --- DEFINISI NAMA TABEL & KOLOM ---
  static const String tableTransactions = 'local_transactions';
  static const String columnLocalId = 'local_id'; // Kunci Utama (Mencegah Duplikat)
  static const String columnNamaMuzakki = 'nama_muzakki';
  static const String columnKategoriZakat = 'kategori_zakat'; // Fitrah, Maal, Profesi
  static const String columnMetodePembayaran = 'metode_pembayaran'; // Tunai, Transfer
  static const String columnJumlah = 'jumlah';
  static const String columnTipeSatuan = 'tipe_satuan'; // 'uang' atau 'beras'
  static const String columnKeterangan = 'keterangan';
  static const String columnCreatedAt = 'created_at';
  
  // Kolom paling krusial untuk fitur Offline-First (0 = Pending, 1 = Synced)
  static const String columnSyncStatus = 'sync_status'; 

  // Inisialisasi Database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      // Mencari folder paling aman di memori internal HP (iOS/Android)
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, 'amil_track_offline.db');
      
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    } catch (e) {
      debugPrint('Error inisialisasi SQLite: $e');
      rethrow;
    }
  }

  // Membuat tabel saat aplikasi pertama kali diinstal
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTransactions (
        $columnLocalId TEXT PRIMARY KEY,
        $columnNamaMuzakki TEXT NOT NULL,
        $columnKategoriZakat TEXT NOT NULL,
        $columnMetodePembayaran TEXT NOT NULL,
        $columnJumlah REAL NOT NULL,
        $columnTipeSatuan TEXT NOT NULL,
        $columnKeterangan TEXT,
        $columnCreatedAt TEXT NOT NULL,
        $columnSyncStatus INTEGER NOT NULL DEFAULT 0
      )
    ''');
    debugPrint('Tabel SQLite local_transactions berhasil dibuat!');
  }

  // ============================================================================
  // FUNGSI CRUD DASAR UNTUK OFFLINE ENGINE
  // ============================================================================

  /// 1. Simpan transaksi ke memori HP (Dipanggil saat amil klik tombol Simpan)
  Future<int> insertTransaction(Map<String, dynamic> row) async {
    try {
      Database db = await instance.database;
      return await db.insert(tableTransactions, row);
    } catch (e) {
      debugPrint('Gagal menyimpan ke SQLite: $e');
      return -1; // Indikator gagal
    }
  }

  /// 2. Ambil semua data yang masih "Nyangkut" (sync_status = 0)
  Future<List<Map<String, dynamic>>> getPendingTransactions() async {
    try {
      Database db = await instance.database;
      return await db.query(
        tableTransactions,
        where: '$columnSyncStatus = ?',
        whereArgs: [0],
      );
    } catch (e) {
      debugPrint('Gagal mengambil data pending: $e');
      return [];
    }
  }

  /// 3. Ubah status menjadi 'Synced' (1) setelah sukses terkirim ke Cloud Supabase
  Future<int> markAsSynced(String localId) async {
    try {
      Database db = await instance.database;
      return await db.update(
        tableTransactions,
        {columnSyncStatus: 1},
        where: '$columnLocalId = ?',
        whereArgs: [localId],
      );
    } catch (e) {
      debugPrint('Gagal mengupdate sync_status: $e');
      return -1;
    }
  }
}