import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../core/constants.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/report_actions_modal.dart';
import '../widgets/whatsapp_receipt_dialog.dart';
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
  DateTimeRange? _selectedDateRange;

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

  Future<void> _pickDateRange() async {
    final initialRange =
        _selectedDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        );

    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      initialDateRange: initialRange,
      confirmText: 'PILIH',
      saveText: 'SIMPAN',
      helpText: 'PILIH RENTANG TANGGAL LAPORAN',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.emeraldDeep,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _selectedDateRange = pickedRange;
      });
    }
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> rawList) {
    return rawList.where((tx) {
      final String nama = (tx[SqliteService.columnNamaMuzakki] ?? '')
          .toString()
          .toLowerCase();
      final String kategori =
          (tx[SqliteService.columnKategoriZakat] ?? 'Fitrah').toString();
      final String rawDate = tx[SqliteService.columnCreatedAt] ?? '';

      final bool matchesSearch = nama.contains(_searchQuery);
      final bool matchesFilter =
          _selectedFilter == 'Semua' || kategori == _selectedFilter;

      bool matchesDate = true;
      if (_selectedDateRange != null && rawDate.isNotEmpty) {
        try {
          final txDate = DateTime.parse(rawDate);
          final startDay = DateTime(
            _selectedDateRange!.start.year,
            _selectedDateRange!.start.month,
            _selectedDateRange!.start.day,
          );
          final endDay = DateTime(
            _selectedDateRange!.end.year,
            _selectedDateRange!.end.month,
            _selectedDateRange!.end.day,
            23,
            59,
            59,
          );

          matchesDate = txDate.isAfter(startDay) && txDate.isBefore(endDay);
        } catch (_) {}
      }

      return matchesSearch && matchesFilter && matchesDate;
    }).toList();
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
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
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: _pickDateRange,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _selectedDateRange == null
                              ? AppColors.softSurface
                              : AppColors.emeraldDeep,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          color: _selectedDateRange == null
                              ? AppColors.emeraldDeep
                              : Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_selectedDateRange != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rentang: ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.emeraldDeep,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _selectedDateRange = null),
                        child: const Text(
                          'Reset Filter X',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fade().slideY(begin: -0.2),
                ],
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
                                if (val) {
                                  setState(() => _selectedFilter = filter);
                                }
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

                final filteredList = _applyFilters(snapshot.data ?? []);

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
                          'Tidak ada riwayat transaksi yang cocok.',
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

                return Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final tx = filteredList[index];
                        final String nama =
                            tx[SqliteService.columnNamaMuzakki] ??
                            'Hamba Allah';
                        final String kategori =
                            tx[SqliteService.columnKategoriZakat] ?? 'Fitrah';
                        final String satuan =
                            tx[SqliteService.columnTipeSatuan] ?? 'uang';
                        final String rawDate =
                            tx[SqliteService.columnCreatedAt] ??
                            DateTime.now().toIso8601String();

                        final double jumlah =
                            (tx[SqliteService.columnJumlah] as num?)
                                ?.toDouble() ??
                            0.0;

                        String displayDate = rawDate;
                        try {
                          displayDate = DateFormat(
                            'dd/MM/yyyy • HH:mm',
                          ).format(DateTime.parse(rawDate));
                        } catch (_) {}

                        final String displayJumlah = (satuan == 'beras')
                            ? '${jumlah.toStringAsFixed(1)} Kg'
                            : currencyFormat.format(jumlah);

                        return TransactionListItem(
                          transaction: tx,
                          nama: nama,
                          kategori: kategori,
                          displayDate: displayDate,
                          displayJumlah: displayJumlah,
                          index: index,
                          getKategoriIcon: _getKategoriIcon,
                          onLongPress: () => showWhatsappReceiptDialog(
                            context: context,
                            transaction: tx,
                            nama: nama,
                            amilName: 'Mochammad Hari Fitrian',
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 24,
                      left: 32,
                      right: 32,
                      child:
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.emeraldDeep.withValues(
                                    alpha: 0.25,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.picture_as_pdf_rounded,
                                size: 20,
                              ),
                              label: const Text(
                                'Ekspor Laporan PDF Resmi',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.emeraldDeep,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () => showReportActionsModal(
                                context: context,
                                filteredTransactions: filteredList,
                                selectedFilter: _selectedFilter,
                                selectedDateRange: _selectedDateRange,
                                amilName: 'Mochammad Hari Fitrian',
                              ),
                            ),
                          ).animate().scale(
                            delay: 300.ms,
                            duration: 400.ms,
                            curve: Curves.elasticOut,
                          ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
