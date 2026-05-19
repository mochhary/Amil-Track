import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../providers/transaction_provider.dart';
import '../services/whatsapp_service.dart';
import '../widgets/transaction_item_card.dart';
import '../widgets/export_modal.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});
  @override
  ConsumerState<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final currentFilter = ref.read(transactionFilterProvider);
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      initialDateRange: currentFilter.dateRange,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.emeraldDeep),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ref
          .read(transactionFilterProvider.notifier)
          .updateFilter(currentFilter.copyWith(dateRange: picked));
    }
  }

  void _showExportModal(
    List<Map<String, dynamic>> list,
    TransactionFilter filter,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ExportDocumentModal(
        filteredList: list,
        selectedFilter: filter.category,
        selectedDateRange: filter.dateRange,
      ),
    );
  }

  void _triggerWhatsapp(Map<String, dynamic> tx, String nama) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Kirim Kwitansi',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.emeraldDeep,
          ),
        ),
        content: Text('Kirim bukti zakat atas nama $nama?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emeraldDeep,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              WhatsappService.instance.sendKwitansi(
                transaction: tx,
                amilName:
                    'Mochammad Hari Fitrian', // Ini akan kita optimasi nanti
                onError: (e) => ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e))),
              );
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncTransactions = ref.watch(filteredTransactionsProvider);
    final currentFilter = ref.watch(transactionFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.softSurface,
      appBar: AppBar(
        title: const Text(
          'Riwayat Setoran',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter & Search Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) {
                      ref
                          .read(transactionFilterProvider.notifier)
                          .updateFilter(currentFilter.copyWith(searchQuery: v));
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari muzakki...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 20,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.softSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: currentFilter.dateRange != null
                        ? AppColors.emeraldDeep
                        : AppColors.softSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _pickDateRange,
                    icon: Icon(
                      Icons.calendar_month_rounded,
                      color: currentFilter.dateRange != null
                          ? Colors.white
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.softSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentFilter.category,
                      icon: const Icon(Icons.filter_list_rounded, size: 18),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      items: ['Semua', 'Fitrah', 'Profesi', 'Maal', 'Fidyah']
                          .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          })
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          ref
                              .read(transactionFilterProvider.notifier)
                              .updateFilter(
                                currentFilter.copyWith(category: val),
                              );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Data List
          Expanded(
            child: asyncTransactions.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.emeraldDeep),
              ),
              error: (err, stack) => Center(
                child: Text(
                  'Terjadi kesalahan: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              data: (filteredList) {
                if (filteredList.isEmpty) {
                  return const Center(
                    child: Text(
                      'Tidak ada riwayat transaksi.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
                      itemCount: filteredList.length,
                      itemBuilder: (_, i) => TransactionItemCard(
                        tx: filteredList[i],
                        onLongPress: _triggerWhatsapp,
                        index: i,
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      left: 32,
                      right: 32,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf_rounded),
                        label: const Text('Ekspor Laporan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.emeraldDeep,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () =>
                            _showExportModal(filteredList, currentFilter),
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
