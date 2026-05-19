import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sqlite_service.dart';

// 1. Pindahkan class struktur data ke sini menjadi publik
class DashboardData {
  final double totalUang;
  final double totalBeras;
  final double fitrahUang;
  final double fitrahBeras;
  final double profesiUang;
  final double maalUang;
  final double fidyahUang;
  final int countFitrah;
  final int countProfesi;
  final int countMaal;
  final int countFidyah;
  final int todayMuzakki;
  final double todayUang;
  final List<Map<String, dynamic>> recentTransactions;

  const DashboardData({
    this.totalUang = 0,
    this.totalBeras = 0,
    this.fitrahUang = 0,
    this.fitrahBeras = 0,
    this.profesiUang = 0,
    this.maalUang = 0,
    this.fidyahUang = 0,
    this.countFitrah = 0,
    this.countProfesi = 0,
    this.countMaal = 0,
    this.countFidyah = 0,
    this.todayMuzakki = 0,
    this.todayUang = 0,
    this.recentTransactions = const [],
  });
}

// 2. Buat Provider khusus untuk memuat dan menyusun data dari SQLite
final localDashboardProvider = FutureProvider<DashboardData>((ref) async {
  final db = await SqliteService.instance.database;
  final todayStr = DateTime.now().toIso8601String().substring(0, 10);

  final String aggregateQuery =
      '''
    SELECT 
      SUM(CASE WHEN ${SqliteService.columnTipeSatuan} = 'uang' THEN ${SqliteService.columnJumlah} ELSE 0 END) as totalUang,
      SUM(CASE WHEN ${SqliteService.columnTipeSatuan} = 'beras' THEN ${SqliteService.columnJumlah} ELSE 0 END) as totalBeras,
      SUM(CASE WHEN ${SqliteService.columnKategoriZakat} = 'Fitrah' AND ${SqliteService.columnTipeSatuan} = 'uang' THEN ${SqliteService.columnJumlah} ELSE 0 END) as fitrahUang,
      SUM(CASE WHEN ${SqliteService.columnKategoriZakat} = 'Fitrah' AND ${SqliteService.columnTipeSatuan} = 'beras' THEN ${SqliteService.columnJumlah} ELSE 0 END) as fitrahBeras,
      SUM(CASE WHEN ${SqliteService.columnKategoriZakat} = 'Profesi' THEN ${SqliteService.columnJumlah} ELSE 0 END) as profesiUang,
      SUM(CASE WHEN ${SqliteService.columnKategoriZakat} = 'Maal' THEN ${SqliteService.columnJumlah} ELSE 0 END) as maalUang,
      SUM(CASE WHEN ${SqliteService.columnKategoriZakat} = 'Fidyah' THEN ${SqliteService.columnJumlah} ELSE 0 END) as fidyahUang,
      SUM(CASE WHEN ${SqliteService.columnKategoriZakat} = 'Fitrah' THEN 1 ELSE 0 END) as countFitrah,
      SUM(CASE WHEN ${SqliteService.columnKategoriZakat} = 'Profesi' THEN 1 ELSE 0 END) as countProfesi,
      SUM(CASE WHEN ${SqliteService.columnKategoriZakat} = 'Maal' THEN 1 ELSE 0 END) as countMaal,
      SUM(CASE WHEN ${SqliteService.columnKategoriZakat} = 'Fidyah' THEN 1 ELSE 0 END) as countFidyah,
      SUM(CASE WHEN ${SqliteService.columnCreatedAt} LIKE '$todayStr%' THEN 1 ELSE 0 END) as todayMuzakki,
      SUM(CASE WHEN ${SqliteService.columnTipeSatuan} = 'uang' AND ${SqliteService.columnCreatedAt} LIKE '$todayStr%' THEN ${SqliteService.columnJumlah} ELSE 0 END) as todayUang
    FROM ${SqliteService.tableTransactions}
  ''';

  final futures = await Future.wait([
    db.rawQuery(aggregateQuery),
    db.query(
      SqliteService.tableTransactions,
      orderBy: '${SqliteService.columnCreatedAt} DESC',
      limit: 4,
    ),
  ]);

  final agg = futures[0].isNotEmpty ? futures[0].first : {};
  final recentTransactions = futures[1] as List<Map<String, dynamic>>;

  return DashboardData(
    totalUang: (agg['totalUang'] as num?)?.toDouble() ?? 0.0,
    totalBeras: (agg['totalBeras'] as num?)?.toDouble() ?? 0.0,
    fitrahUang: (agg['fitrahUang'] as num?)?.toDouble() ?? 0.0,
    fitrahBeras: (agg['fitrahBeras'] as num?)?.toDouble() ?? 0.0,
    profesiUang: (agg['profesiUang'] as num?)?.toDouble() ?? 0.0,
    maalUang: (agg['maalUang'] as num?)?.toDouble() ?? 0.0,
    fidyahUang: (agg['fidyahUang'] as num?)?.toDouble() ?? 0.0,
    countFitrah: agg['countFitrah'] as int? ?? 0,
    countProfesi: agg['countProfesi'] as int? ?? 0,
    countMaal: agg['countMaal'] as int? ?? 0,
    countFidyah: agg['countFidyah'] as int? ?? 0,
    todayMuzakki: agg['todayMuzakki'] as int? ?? 0,
    todayUang: (agg['todayUang'] as num?)?.toDouble() ?? 0.0,
    recentTransactions: recentTransactions,
  );
});
