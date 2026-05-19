import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';

// 1. Provider untuk mengambil Total Zakat (Uang & Beras) yang terkumpul
final zakatTotalsProvider = FutureProvider<Map<String, double>>((ref) async {
  // Mengambil data langsung dari service yang sudah Anda buat sebelumnya
  return await SupabaseService.instance.fetchCollectedTotalsByType();
});

// 2. Provider untuk mengambil Daftar Riwayat Transaksi Terbaru
final recentTransactionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // Mengambil daftar transaksi, otomatis diurutkan dari yang terbaru
  return await SupabaseService.instance.fetchTransactions();
});