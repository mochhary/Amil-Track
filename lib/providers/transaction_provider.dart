import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sqlite_service.dart';

// 1. Filter Model
class TransactionFilter {
  final String searchQuery;
  final String category;
  final DateTimeRange? dateRange;

  const TransactionFilter({
    this.searchQuery = '',
    this.category = 'Semua',
    this.dateRange,
  });

  // Helper untuk update state agar immutability terjaga
  TransactionFilter copyWith({
    String? searchQuery,
    String? category,
    DateTimeRange? dateRange,
  }) {
    return TransactionFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
      dateRange: dateRange ?? this.dateRange,
    );
  }
}

// 2. Notifier (Pengganti StateNotifier/StateProvider yang sering error)
class TransactionFilterNotifier extends Notifier<TransactionFilter> {
  @override
  TransactionFilter build() => const TransactionFilter();

  void updateFilter(TransactionFilter newFilter) {
    state = newFilter;
  }
}

// 3. Provider Utama
final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilter>(() {
      return TransactionFilterNotifier();
    });

// 4. Provider Data (Tetap)
final rawTransactionsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final db = await SqliteService.instance.database;
  return await db.query(
    SqliteService.tableTransactions,
    orderBy: '${SqliteService.columnCreatedAt} DESC',
  );
});

// 5. Provider Filtered (Menggunakan watch)
final filteredTransactionsProvider =
    Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
      final rawData = ref.watch(rawTransactionsProvider);
      final filter = ref.watch(transactionFilterProvider);

      return rawData.whenData((list) {
        return list.where((tx) {
          final String nama = (tx[SqliteService.columnNamaMuzakki] ?? '')
              .toString()
              .toLowerCase();
          final String kategori =
              (tx[SqliteService.columnKategoriZakat] ?? 'Fitrah').toString();

          bool matchesSearch = nama.contains(filter.searchQuery.toLowerCase());
          bool matchesFilter =
              filter.category == 'Semua' || kategori == filter.category;
          return matchesSearch && matchesFilter;
        }).toList();
      });
    });
