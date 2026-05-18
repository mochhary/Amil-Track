import 'package:flutter/foundation.dart'; // TAMBAHAN UNTUK DEBUG PRINT
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sqlite_service.dart';

class SyncService {
  SyncService._privateConstructor();
  static final SyncService instance = SyncService._privateConstructor();

  final _supabase = Supabase.instance.client;

  // Gembok agar mesin tidak jalan ganda dan bertabrakan
  bool _isSyncing = false;

  // ==========================================================
  // MASTER FUNGSI: SINKRONISASI DUA ARAH (TWO-WAY AUTO SYNC)
  // ==========================================================
  Future<bool> autoSync() async {
    if (_isSyncing) return false;
    _isSyncing = true;
    bool uiNeedsRefresh = false;

    try {
      final db = await SqliteService.instance.database;

      // --------------------------------------------------------
      // TAHAP 1: PUSH (Kirim Data Baru dari Lokal ke Cloud)
      // --------------------------------------------------------
      final pendingRecords = await db.query(
        SqliteService.tableTransactions,
        where: '${SqliteService.columnSyncStatus} = ?',
        whereArgs: [0],
      );

      for (var record in pendingRecords) {
        await _supabase.from('zakat_transactions').insert({
          'nama_muzakki': record[SqliteService.columnNamaMuzakki],
          'kategori_zakat': record[SqliteService.columnKategoriZakat],
          'jumlah': record[SqliteService.columnJumlah],
          'tipe_satuan': record[SqliteService.columnTipeSatuan],
          'jumlah_jiwa': record[SqliteService.columnJumlahJiwa],
          'created_at': record[SqliteService.columnCreatedAt],
        });

        await db.update(
          SqliteService.tableTransactions,
          {SqliteService.columnSyncStatus: 1},
          where: '${SqliteService.columnId} = ?',
          whereArgs: [record[SqliteService.columnId]],
        );
      }

      // --------------------------------------------------------
      // TAHAP 2: PULL (Tarik Data Baru dari Cloud ke Lokal)
      // --------------------------------------------------------
      // Cek kapan terakhir kali aplikasi kita menyimpan data
      final maxDateRes = await db.rawQuery(
        'SELECT MAX(${SqliteService.columnCreatedAt}) as max_date FROM ${SqliteService.tableTransactions}',
      );
      final String? latestLocalTime = maxDateRes.first['max_date'] as String?;

      List<dynamic> cloudData;
      if (latestLocalTime != null) {
        // Jika sudah ada data, cukup tarik data yang LEBIH BARU dari waktu lokal terakhir
        cloudData = await _supabase
            .from('zakat_transactions')
            .select()
            .gt('created_at', latestLocalTime);
      } else {
        // Jika lokal kosong (baru diinstal), tarik seluruh isi Supabase
        cloudData = await _supabase.from('zakat_transactions').select();
      }

      for (var record in cloudData) {
        // Proteksi Lapis Baja: Pastikan data belum ada di SQLite sebelum disuntikkan
        final existing = await db.query(
          SqliteService.tableTransactions,
          where: '${SqliteService.columnCreatedAt} = ?',
          whereArgs: [record['created_at']],
        );

        if (existing.isEmpty) {
          await db.insert(SqliteService.tableTransactions, {
            SqliteService.columnNamaMuzakki: record['nama_muzakki'],
            SqliteService.columnKategoriZakat: record['kategori_zakat'],
            SqliteService.columnJumlah: record['jumlah'],
            SqliteService.columnTipeSatuan: record['tipe_satuan'] ?? 'uang',
            SqliteService.columnJumlahJiwa: record['jumlah_jiwa'],
            SqliteService.columnCreatedAt: record['created_at'],
            SqliteService.columnSyncStatus: 1, // Langsung cap tersinkronisasi
          });
          uiNeedsRefresh =
              true; // Beri sinyal ke layar utama untuk memperbarui angka
        }
      }
    } catch (e) {
      debugPrint('[AUTO-SYNC ERROR]: $e'); // UBAH KE DEBUGPRINT
    } finally {
      _isSyncing = false;
    }

    return uiNeedsRefresh;
  }
}
