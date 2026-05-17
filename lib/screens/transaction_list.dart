import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../core/constants.dart';
import '../widgets/soft_surface_card.dart';
import '../services/sqlite_service.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  late Future<List<Map<String, dynamic>>> _transactionsFuture;
  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    setState(() {
      _transactionsFuture = _fetchTransactionsFromLocal();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchTransactionsFromLocal() async {
    final db = await SqliteService.instance.database;
    return await db.query(
      SqliteService.tableTransactions,
      orderBy: '${SqliteService.columnCreatedAt} DESC',
    );
  }

  IconData _getKategoriIcon(String kategori) {
    switch (kategori) {
      case 'Fitrah':
        return Icons.rice_bowl_rounded;
      case 'Profesi':
        return Icons.work_outline_rounded;
      case 'Maal':
        return Icons.account_balance_rounded;
      case 'Fidyah':
        return Icons.calendar_today_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.softSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Riwayat Setoran Muzakki',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.emeraldDeep,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.emeraldDeep,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) =>
                      setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Cari nama muzakki...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.emeraldDeep,
                    ),
                    filled: true,
                    fillColor: AppColors.softSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['Semua', 'Fitrah', 'Profesi', 'Maal', 'Fidyah']
                        .map((filter) {
                          final bool isSelected = _selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                filter,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.emeraldDeep,
                              backgroundColor: AppColors.softSurface,
                              showCheckmark: false,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onSelected: (val) {
                                if (val)
                                  setState(() => _selectedFilter = filter);
                              },
                            ),
                          );
                        })
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.emeraldDeep,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final rawList = snapshot.data ?? [];

                final filteredList = rawList.where((tx) {
                  final String nama =
                      (tx[SqliteService.columnNamaMuzakki] ?? '')
                          .toString()
                          .toLowerCase();
                  final String kategori =
                      (tx[SqliteService.columnKategoriZakat] ?? 'Fitrah')
                          .toString();

                  final bool matchesSearch = nama.contains(_searchQuery);
                  final bool matchesFilter =
                      _selectedFilter == 'Semua' || kategori == _selectedFilter;

                  return matchesSearch && matchesFilter;
                }).toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.layers_clear_rounded,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada riwayat transaksi.',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final tx = filteredList[index];
                    final String nama =
                        tx[SqliteService.columnNamaMuzakki] ?? 'Hamba Allah';
                    final String kategori =
                        tx[SqliteService.columnKategoriZakat] ?? 'Fitrah';
                    final String satuan =
                        tx[SqliteService.columnTipeSatuan] ?? 'uang';
                    final String rawDate =
                        tx[SqliteService.columnCreatedAt] ??
                        DateTime.now().toIso8601String();

                    final double jumlah =
                        (tx[SqliteService.columnJumlah] as num?)?.toDouble() ??
                        0.0;

                    // =========================================================
                    // FIX WAKTU: Format tanggal jam estetik dan anti-error
                    // Output: 17/05/2026 • 18:16
                    // =========================================================
                    String displayDate = rawDate;
                    try {
                      final parsedDate = DateTime.parse(rawDate);
                      displayDate = DateFormat(
                        'dd/MM/yyyy • HH:mm',
                      ).format(parsedDate);
                    } catch (_) {}

                    final String displayJumlah = (satuan == 'beras')
                        ? '${jumlah.toStringAsFixed(1)} Kg'
                        : currencyFormat.format(jumlah);

                    return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SoftSurfaceCard(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.softSurface,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    _getKategoriIcon(kategori),
                                    size: 22,
                                    color: AppColors.emeraldDeep,
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
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Zakat $kategori • $displayDate',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  displayJumlah,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    color: AppColors.emeraldDeep,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .fade(duration: 200.ms, delay: (index * 50).ms)
                        .slideX(begin: 0.03);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
