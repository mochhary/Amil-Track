import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sqlite_service.dart';

class SyncService {
  static final SyncService instance = SyncService._init();
  SyncService._init();

  bool _isSyncing = false;

  Future<String> syncPendingData() async {
    if (_isSyncing) return 'Sinkronisasi sedang berjalan di latar belakang.';
    _isSyncing = true;

    try {
      final db = await SqliteService.instance.database;
      final pendingRows = await db.query(
        SqliteService.tableTransactions,
        where: '${SqliteService.columnSyncStatus} = ?',
        whereArgs: [0],
      );

      if (pendingRows.isEmpty) {
        _isSyncing = false;
        return 'Seluruh data telah tersinkronisasi.';
      }

      final supabase = Supabase.instance.client;
      int successCount = 0;
      String lastErrorMessage = '';

      for (final row in pendingRows) {
        try {
          final Map<String, dynamic> payload = {
            'nama_muzakki': row[SqliteService.columnNamaMuzakki],
            'kategori_zakat': row[SqliteService.columnKategoriZakat],
            'tipe_bayar': row[SqliteService.columnTipeSatuan],
            'total_bayar': row[SqliteService.columnJumlah],
            'jumlah_jiwa': 1,
            'created_at': row[SqliteService.columnCreatedAt],
          };

          await supabase.from('zakat_transactions').insert(payload);

          await db.update(
            SqliteService.tableTransactions,
            {SqliteService.columnSyncStatus: 1},
            where: '${SqliteService.columnLocalId} = ?',
            whereArgs: [row[SqliteService.columnLocalId]],
          );
          
          successCount++;
        } catch (e) {
          lastErrorMessage = e.toString();
          debugPrint('Supabase Error: $lastErrorMessage');
        }
      }

      if (successCount == pendingRows.length) {
        return 'Berhasil menyinkronkan $successCount data ke server.';
      } else {
        return 'Gagal menyinkronkan beberapa data. Sistem akan mencoba lagi nanti.';
      }
    } catch (e) {
      return 'Terjadi kesalahan sistem sinkronisasi.';
    } finally {
      _isSyncing = false;
    }
  }
}