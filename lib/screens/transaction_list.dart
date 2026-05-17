import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/app_watermark_background.dart';
import '../widgets/soft_surface_card.dart';
import '../services/sqlite_service.dart';
import '../services/supabase_service.dart';
import '../services/sync_service.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  late Future<List<Map<String, dynamic>>> _transactionsFuture;
  String _filterKategori = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    setState(() {
      _transactionsFuture = _fetchLocalTransactions();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchLocalTransactions() async {
    final db = await SqliteService.instance.database;
    if (_filterKategori != 'Semua') {
      return await db.query(
        SqliteService.tableTransactions,
        where: '${SqliteService.columnKategoriZakat} = ?',
        whereArgs: [_filterKategori],
        orderBy: '${SqliteService.columnCreatedAt} DESC',
      );
    }
    return await db.query(
      SqliteService.tableTransactions,
      orderBy: '${SqliteService.columnCreatedAt} DESC',
    );
  }

  // Fungsi untuk Pull to Refresh
  Future<void> _handleRefresh() async {
    // 1. Jalankan sinkronisasi background secara senyap
    await SyncService.instance.syncPendingData();
    // 2. Muat ulang data lokal
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return AppWatermarkBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text(
            'Riwayat Setoran',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                children: ['Semua', 'Fitrah', 'Profesi', 'Maal'].map((
                  kategori,
                ) {
                  final isSelected = _filterKategori == kategori;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        kategori == 'Semua'
                            ? 'Semua Kategori'
                            : 'Zakat $kategori',
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.emerald,
                      backgroundColor: Colors.white.withValues(alpha: 0.6),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide.none,
                      showCheckmark: false,
                      onSelected: (bool selected) {
                        if (selected) {
                          setState(() => _filterKategori = kategori);
                          _loadTransactions();
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              // Menambahkan Pull-to-Refresh
              child: RefreshIndicator(
                color: AppColors.emerald,
                onRefresh: _handleRefresh,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _transactionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.emerald,
                        ),
                      );
                    final txList = snapshot.data ?? [];

                    if (txList.isEmpty) {
                      return ListView(
                        physics:
                            const AlwaysScrollableScrollPhysics(), // Agar tetap bisa di-pull refresh saat kosong
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                          ),
                          Icon(
                            Icons.folder_open_rounded,
                            size: 64,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              'Belum ada data transaksi $_filterKategori.',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                      itemCount: txList.length,
                      itemBuilder: (context, index) {
                        final tx = txList[index];
                        final String nama =
                            tx[SqliteService.columnNamaMuzakki] ??
                            'Hamba Allah';
                        final String kategori =
                            tx[SqliteService.columnKategoriZakat] ?? 'Fitrah';
                        final String metode =
                            tx[SqliteService.columnMetodePembayaran] ?? 'Tunai';
                        final double jumlah =
                            tx[SqliteService.columnJumlah] ?? 0.0;
                        final String satuan =
                            tx[SqliteService.columnTipeSatuan] ?? 'uang';

                        final String displayJumlah =
                            (kategori == 'Fitrah' && satuan == 'beras')
                            ? '${jumlah.toStringAsFixed(1)} Kg Beras'
                            : SupabaseService.instance.formatCurrency(jumlah);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SoftSurfaceCard(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.9,
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color:
                                        (kategori == 'Maal'
                                                ? AppColors.gold
                                                : AppColors.emerald)
                                            .withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    kategori == 'Fitrah'
                                        ? Icons.rice_bowl_rounded
                                        : kategori == 'Profesi'
                                        ? Icons.work_outline_rounded
                                        : Icons.account_balance_rounded,
                                    color: kategori == 'Maal'
                                        ? AppColors.gold
                                        : AppColors.emeraldDeep,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nama,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.softSurface,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              kategori,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'via $metode',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // UI Sync Dihapus, Sisakan Jumlah Zakat Saja
                                Text(
                                  displayJumlah,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    color: kategori == 'Maal'
                                        ? Colors.amber.shade900
                                        : AppColors.emeraldDeep,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
