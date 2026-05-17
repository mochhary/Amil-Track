import 'dart:io';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants.dart';
import '../widgets/soft_surface_card.dart';
import '../widgets/app_watermark_background.dart';
import '../widgets/glass_container.dart';
import 'transaction_form.dart';
import 'transaction_list.dart';
import '../services/auth_service.dart';
import '../services/sqlite_service.dart';
import '../services/sync_service.dart';

class _DashboardData {
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

  const _DashboardData({
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

Future<void> _launchWithConfirmation(
  BuildContext context,
  String urlString,
  String title,
  String message,
) async {
  final bool? confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white.withValues(alpha: 0.95),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          color: AppColors.emeraldDeep,
          fontSize: 18,
        ),
      ),
      content: Text(
        message,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(
            'Batal',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.emerald,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text(
            'Ya, Lanjutkan',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    ),
  );
  if (confirm == true) {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka tautan eksternal.')),
        );
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.username});
  final String username;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_DashboardData> _dashboardFuture;
  int _selectedTab = 0;
  bool _isOnline = true;
  bool _wasOffline = false;
  Timer? _networkTimer;
  late String _currentUsername;

  @override
  void initState() {
    super.initState();
    _currentUsername = widget.username;

    // 1. RENDER INSTAN: Langsung tampilkan memori lokal (Offline-First) agar UI cepat
    _dashboardFuture = _loadDashboardData();

    // 2. KEAJAIBAN AWAL: Tarik data dari Supabase secara siluman, lalu auto-refresh UI
    _initialMagicSync();

    // 3. RADAR AUTO-SYNC: Jalan setiap 4 detik untuk mengecek jika ada data baru
    _networkTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _backgroundSync(),
    );
  }

  @override
  void dispose() {
    _networkTimer?.cancel();
    super.dispose();
  }

  // Fungsi khusus untuk sinkronisasi pertama kali buka aplikasi
  Future<void> _initialMagicSync() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (mounted) setState(() => _isOnline = true);

        bool hasNewData = await SyncService.instance.autoSync();
        // AUTO REFRESH: Jika ada data dari Supabase (misal sehabis install ulang), layar langsung update!
        if (hasNewData && mounted) {
          _refreshDashboard();
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isOnline = false);
    }
  }

  // Fungsi pengawas latar belakang setiap 4 detik
  Future<void> _backgroundSync() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (!_isOnline && mounted) {
          setState(() {
            _isOnline = true;
            _wasOffline = true;
          });
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) setState(() => _wasOffline = false);
          });
        }

        bool hasNewData = await SyncService.instance.autoSync();
        if (hasNewData && mounted) {
          _refreshDashboard(); // Layar akan terbarui otomatis jika ada data baru masuk dari awan
        }
      }
    } catch (_) {
      if (_isOnline && mounted) setState(() => _isOnline = false);
    }
  }

  void _refreshDashboard() {
    if (mounted) {
      setState(() {
        _dashboardFuture = _loadDashboardData();
      });
    }
  }

  Future<_DashboardData> _loadDashboardData() async {
    final db = await SqliteService.instance.database;
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);

    final futures = await Future.wait([
      db.rawQuery(
        'SELECT SUM(${SqliteService.columnJumlah}) as total FROM ${SqliteService.tableTransactions} WHERE ${SqliteService.columnTipeSatuan} = "uang"',
      ),
      db.rawQuery(
        'SELECT SUM(${SqliteService.columnJumlah}) as total FROM ${SqliteService.tableTransactions} WHERE ${SqliteService.columnTipeSatuan} = "beras"',
      ),
      db.rawQuery(
        'SELECT SUM(${SqliteService.columnJumlah}) as total FROM ${SqliteService.tableTransactions} WHERE ${SqliteService.columnKategoriZakat} = "Fitrah" AND ${SqliteService.columnTipeSatuan} = "uang"',
      ),
      db.rawQuery(
        'SELECT SUM(${SqliteService.columnJumlah}) as total FROM ${SqliteService.tableTransactions} WHERE ${SqliteService.columnKategoriZakat} = "Fitrah" AND ${SqliteService.columnTipeSatuan} = "beras"',
      ),
      db.rawQuery(
        'SELECT SUM(${SqliteService.columnJumlah}) as total FROM ${SqliteService.tableTransactions} WHERE ${SqliteService.columnKategoriZakat} = "Profesi"',
      ),
      db.rawQuery(
        'SELECT SUM(${SqliteService.columnJumlah}) as total FROM ${SqliteService.tableTransactions} WHERE ${SqliteService.columnKategoriZakat} = "Maal"',
      ),
      db.rawQuery(
        'SELECT SUM(${SqliteService.columnJumlah}) as total FROM ${SqliteService.tableTransactions} WHERE ${SqliteService.columnKategoriZakat} = "Fidyah"',
      ),
      db.rawQuery(
        'SELECT COUNT(*) as c FROM ${SqliteService.tableTransactions} WHERE ${SqliteService.columnKategoriZakat} = "Fitrah"',
      ),
      db.rawQuery(
        'SELECT COUNT(*) as c FROM ${SqliteService.tableTransactions} WHERE ${SqliteService.columnKategoriZakat} = "Profesi"',
      ),
      db.rawQuery(
        'SELECT COUNT(*) as c FROM ${SqliteService.tableTransactions} WHERE ${SqliteService.columnKategoriZakat} = "Maal"',
      ),
      db.rawQuery(
        'SELECT COUNT(*) as c FROM ${SqliteService.tableTransactions} WHERE ${SqliteService.columnKategoriZakat} = "Fidyah"',
      ),
      db.rawQuery(
        "SELECT COUNT(*) as c FROM ${SqliteService.tableTransactions} WHERE ${SqliteService.columnCreatedAt} LIKE '$todayStr%'",
      ),
      db.rawQuery(
        "SELECT SUM(${SqliteService.columnJumlah}) as total FROM ${SqliteService.tableTransactions} WHERE ${SqliteService.columnTipeSatuan} = 'uang' AND ${SqliteService.columnCreatedAt} LIKE '$todayStr%'",
      ),
      db.query(
        SqliteService.tableTransactions,
        orderBy: '${SqliteService.columnCreatedAt} DESC',
        limit: 4,
      ),
    ]);

    return _DashboardData(
      totalUang: (futures[0].first['total'] as num?)?.toDouble() ?? 0.0,
      totalBeras: (futures[1].first['total'] as num?)?.toDouble() ?? 0.0,
      fitrahUang: (futures[2].first['total'] as num?)?.toDouble() ?? 0.0,
      fitrahBeras: (futures[3].first['total'] as num?)?.toDouble() ?? 0.0,
      profesiUang: (futures[4].first['total'] as num?)?.toDouble() ?? 0.0,
      maalUang: (futures[5].first['total'] as num?)?.toDouble() ?? 0.0,
      fidyahUang: (futures[6].first['total'] as num?)?.toDouble() ?? 0.0,
      countFitrah: futures[7].first['c'] as int? ?? 0,
      countProfesi: futures[8].first['c'] as int? ?? 0,
      countMaal: futures[9].first['c'] as int? ?? 0,
      countFidyah: futures[10].first['c'] as int? ?? 0,
      todayMuzakki: futures[11].first['c'] as int? ?? 0,
      todayUang: (futures[12].first['total'] as num?)?.toDouble() ?? 0.0,
      recentTransactions: futures[13] as List<Map<String, dynamic>>,
    );
  }

  Widget _buildClassicNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.emeraldDeep : Colors.grey.shade500,
              size: 26,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                color: isActive ? AppColors.emeraldDeep : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isActive ? 1.0 : 0.0,
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.emeraldDeep,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AppWatermarkBackground(
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,

        body: FutureBuilder<_DashboardData>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.emeraldDeep),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Gagal memuat data dashboard: ${snapshot.error}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            final data = snapshot.data ?? const _DashboardData();

            return Stack(
              children: [
                Positioned.fill(
                  child: IndexedStack(
                    index: _selectedTab,
                    children: [
                      RefreshIndicator(
                        onRefresh: () async {
                          await SyncService.instance.autoSync();
                          _refreshDashboard();
                        },
                        color: AppColors.emerald,
                        edgeOffset: topPadding + 80,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            20,
                            topPadding + 90,
                            20,
                            140 + bottomPadding,
                          ),
                          children: [
                            _HeroDashboardCard(
                                  username: _currentUsername,
                                  totalUang: data.totalUang,
                                  totalBeras: data.totalBeras,
                                  fitrahUang: data.fitrahUang,
                                  fitrahBeras: data.fitrahBeras,
                                  profesiUang: data.profesiUang,
                                  maalUang: data.maalUang,
                                  fidyahUang: data.fidyahUang,
                                  todayCount: data.todayMuzakki,
                                )
                                .animate()
                                .fade(duration: 400.ms)
                                .slideY(begin: 0.05),
                            const SizedBox(height: 24),
                            const Text(
                              'Peralatan Amil',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: AppColors.emeraldDeep,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _ActionGrid(
                              todayMuzakki: data.todayMuzakki,
                              todayUang: data.todayUang,
                            ),
                            const SizedBox(height: 24),
                            _DistributionMiniChart(
                              fitrah: data.countFitrah,
                              profesi: data.countProfesi,
                              maal: data.countMaal,
                              fidyah: data.countFidyah,
                            ),
                            const SizedBox(height: 24),
                            _ActivityFeed(
                              transactions: data.recentTransactions,
                              onSeeAll: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const TransactionListScreen(),
                                  ),
                                );
                                _refreshDashboard();
                              },
                            ),
                          ],
                        ),
                      ),
                      ListView(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          topPadding + 90,
                          20,
                          140 + bottomPadding,
                        ),
                        children: [
                          _ProfileTabContent(
                            username: _currentUsername,
                            email: AuthService.instance.currentUser?.email,
                            totalMuzakkiCount:
                                data.countFitrah +
                                data.countProfesi +
                                data.countMaal +
                                data.countFidyah,
                            onLogout: () async =>
                                await AuthService.instance.signOut(),
                            onDeleteAccount: () async =>
                                await AuthService.instance.deleteAccount(),
                            onUpdateProfile: (newName) {
                              setState(() => _currentUsername = newName);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Positioned(
                  top: topPadding + 12,
                  left: 20,
                  right: 20,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.35),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Text(
                              _selectedTab == 0 ? 'Amil Track' : 'Profil Amil',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppColors.emeraldDeep,
                                fontSize: 18,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.emeraldDeep,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.mosque_rounded,
                                    color: AppColors.gold,
                                    size: 14,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'AT',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.gold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 24 + bottomPadding,
                  left: 20,
                  right: 20,
                  height: 65,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _CustomLiquidNotchPainter(
                              radius: 32.0,
                              color: Colors.white.withValues(alpha: 0.45),
                              notchRadius: 36.0,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 30.0,
                                sigmaY: 30.0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: Row(
                                  children: [
                                    _buildClassicNavItem(
                                      icon: Icons.home_rounded,
                                      label: 'Amil',
                                      isActive: _selectedTab == 0,
                                      onTap: () =>
                                          setState(() => _selectedTab = 0),
                                    ),
                                    const SizedBox(width: 80),
                                    _buildClassicNavItem(
                                      icon: Icons.person_rounded,
                                      label: 'Profile',
                                      isActive: _selectedTab == 1,
                                      onTap: () =>
                                          setState(() => _selectedTab = 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: 24 + bottomPadding + 32,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      height: 58,
                      width: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.orangeGold.withValues(alpha: 0.45),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: FloatingActionButton(
                        elevation: 0,
                        backgroundColor: AppColors.orangeGold,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TransactionFormScreen(),
                            ),
                          );
                          if (result == true) _refreshDashboard();
                        },
                        child: const Icon(Icons.add_rounded, size: 34),
                      ),
                    ),
                  ),
                ),

                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  bottom: 110 + bottomPadding,
                  left: 30,
                  right: 30,
                  child: IgnorePointer(
                    child:
                        Container(
                              height: 32,
                              decoration: BoxDecoration(
                                color: _isOnline
                                    ? Colors.green.shade700
                                    : Colors.black87,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _isOnline
                                    ? 'Kembali online'
                                    : 'Tidak ada koneksi internet',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                            .animate(
                              target: (!_isOnline || _wasOffline) ? 1 : 0,
                            )
                            .fade(duration: 200.ms)
                            .slideY(begin: 1, end: 0),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CustomLiquidNotchPainter extends CustomPainter {
  final double radius;
  final Color color;
  final double notchRadius;
  _CustomLiquidNotchPainter({
    required this.radius,
    required this.color,
    required this.notchRadius,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(radius, 0);
    path.lineTo(w / 2 - notchRadius - 10, 0);
    path.cubicTo(
      w / 2 - notchRadius,
      0,
      w / 2 - notchRadius + 6,
      h * 0.72,
      w / 2,
      h * 0.72,
    );
    path.cubicTo(
      w / 2 + notchRadius - 6,
      h * 0.72,
      w / 2 + notchRadius,
      0,
      w / 2 + notchRadius + 10,
      0,
    );

    path.lineTo(w - radius, 0);
    path.arcToPoint(
      Offset(w, radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );
    path.lineTo(w, h - radius);
    path.arcToPoint(
      Offset(w - radius, h),
      radius: Radius.circular(radius),
      clockwise: true,
    );
    path.lineTo(radius, h);
    path.arcToPoint(
      Offset(0, h - radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );
    path.lineTo(0, radius);
    path.arcToPoint(
      Offset(radius, 0),
      radius: Radius.circular(radius),
      clockwise: true,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldReclip(covariant CustomPainter oldClipper) => false;
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroDashboardCard extends StatefulWidget {
  final String username;
  final double totalUang;
  final double totalBeras;
  final double fitrahUang;
  final double fitrahBeras;
  final double profesiUang;
  final double maalUang;
  final double fidyahUang;
  final int todayCount;

  const _HeroDashboardCard({
    required this.username,
    required this.totalUang,
    required this.totalBeras,
    required this.fitrahUang,
    required this.fitrahBeras,
    required this.profesiUang,
    required this.maalUang,
    required this.fidyahUang,
    required this.todayCount,
  });

  @override
  State<_HeroDashboardCard> createState() => _HeroDashboardCardState();
}

class _HeroDashboardCardState extends State<_HeroDashboardCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildCardSlide({
    required String title,
    required String valueUang,
    String? valueBeras,
    required List<Color> colors,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            top: -15,
            child: Icon(
              icon,
              size: 130,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assalamu\'alaikum,',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            widget.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.people_alt_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.todayCount} Hari Ini',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valueUang,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                if (valueBeras != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.rice_bowl_rounded,
                          color: AppColors.gold,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          valueBeras,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final slides = [
      _buildCardSlide(
        title: 'TOTAL SEMUA ZAKAT',
        valueUang: currencyFormat.format(widget.totalUang),
        valueBeras: 'Sembako Beras: ${widget.totalBeras.toStringAsFixed(1)} Kg',
        colors: [AppColors.emeraldDeep, AppColors.emerald],
        icon: Icons.account_balance_wallet_rounded,
      ),
      _buildCardSlide(
        title: 'TOTAL ZAKAT FITRAH',
        valueUang: currencyFormat.format(widget.fitrahUang),
        valueBeras: 'Beras Fitrah: ${widget.fitrahBeras.toStringAsFixed(1)} Kg',
        colors: [AppColors.emeraldDeep, Colors.teal.shade700],
        icon: Icons.rice_bowl_rounded,
      ),
      _buildCardSlide(
        title: 'TOTAL ZAKAT PROFESI',
        valueUang: currencyFormat.format(widget.profesiUang),
        colors: [AppColors.emeraldDeep, AppColors.orangeGold],
        icon: Icons.work_outline_rounded,
      ),
      _buildCardSlide(
        title: 'TOTAL ZAKAT MAAL',
        valueUang: currencyFormat.format(widget.maalUang),
        colors: [AppColors.emeraldDeep, AppColors.gold],
        icon: Icons.account_balance_rounded,
      ),
      _buildCardSlide(
        title: 'TOTAL DANA FIDYAH',
        valueUang: currencyFormat.format(widget.fidyahUang),
        colors: [AppColors.emeraldDeep, Colors.purple.shade700],
        icon: Icons.calendar_today_rounded,
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 195,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: slides,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            slides.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppColors.emeraldDeep
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionGrid extends StatelessWidget {
  final int todayMuzakki;
  final double todayUang;
  const _ActionGrid({required this.todayMuzakki, required this.todayUang});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BeautifulActionTile(
            icon: Icons.insights_rounded,
            title: 'Cek\nNisab',
            iconColor: Colors.purple,
            bgColor: Colors.purple.withValues(alpha: 0.08),
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => const _NisabModal(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BeautifulActionTile(
            icon: Icons.share_rounded,
            title: 'Kirim\nRekap',
            iconColor: Colors.blue.shade700,
            bgColor: Colors.blue.withValues(alpha: 0.08),
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) =>
                  _RekapHarianModal(muzakki: todayMuzakki, uang: todayUang),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BeautifulActionTile(
            icon: Icons.menu_book_rounded,
            title: 'Panduan\nFikih',
            iconColor: Colors.teal,
            bgColor: Colors.teal.withValues(alpha: 0.08),
            onTap: () => _launchWithConfirmation(
              context,
              'https://baznas.go.id',
              'Buka Situs BAZNAS',
              'Anda akan diarahkan ke browser luar untuk melihat panduan resmi. Lanjutkan?',
            ),
          ),
        ),
      ],
    );
  }
}

class _BeautifulActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;
  const _BeautifulActionTile({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 26),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DistributionMiniChart extends StatelessWidget {
  final int fitrah;
  final int profesi;
  final int maal;
  final int fidyah;
  const _DistributionMiniChart({
    required this.fitrah,
    required this.profesi,
    required this.maal,
    required this.fidyah,
  });

  @override
  Widget build(BuildContext context) {
    final int total = fitrah + profesi + maal + fidyah;
    final int flexFitrah = total > 0 ? ((fitrah / total) * 100).round() : 0;
    final int flexProfesi = total > 0 ? ((profesi / total) * 100).round() : 0;
    final int flexMaal = total > 0 ? ((maal / total) * 100).round() : 0;
    final int flexFidyah = total > 0 ? ((fidyah / total) * 100).round() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Metrik Sebaran Zakat & Fidyah',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: AppColors.emeraldDeep,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 12,
            child: total == 0
                ? Container(color: Colors.grey.withValues(alpha: 0.3))
                : Row(
                    children: [
                      if (flexFitrah > 0)
                        Expanded(
                          flex: flexFitrah,
                          child: Container(color: AppColors.emerald),
                        ),
                      if (flexProfesi > 0)
                        Expanded(
                          flex: flexProfesi,
                          child: Container(color: AppColors.orangeGold),
                        ),
                      if (flexMaal > 0)
                        Expanded(
                          flex: flexMaal,
                          child: Container(color: AppColors.gold),
                        ),
                      if (flexFidyah > 0)
                        Expanded(
                          flex: flexFidyah,
                          child: Container(color: Colors.purple.shade700),
                        ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            _ChartIndicatorTag(
              label: 'Fitrah ($fitrah)',
              color: AppColors.emerald,
            ),
            _ChartIndicatorTag(
              label: 'Profesi ($profesi)',
              color: AppColors.orangeGold,
            ),
            _ChartIndicatorTag(label: 'Maal ($maal)', color: AppColors.gold),
            _ChartIndicatorTag(
              label: 'Fidyah ($fidyah)',
              color: Colors.purple.shade700,
            ),
          ],
        ),
      ],
    );
  }
}

class _ChartIndicatorTag extends StatelessWidget {
  final String label;
  final Color color;
  const _ChartIndicatorTag({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ActivityFeed extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final VoidCallback onSeeAll;
  const _ActivityFeed({required this.transactions, required this.onSeeAll});

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Setoran Terkini',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: AppColors.emeraldDeep,
              ),
            ),
            TextButton(
              onPressed: onSeeAll,
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  color: AppColors.emerald,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        if (transactions.isEmpty)
          SoftSurfaceCard(
            backgroundColor: Colors.white.withValues(alpha: 0.85),
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'Belum ada transaksi.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          )
        else
          ...transactions.map((tx) {
            final String nama =
                tx[SqliteService.columnNamaMuzakki] ?? 'Hamba Allah';
            final String kategori =
                tx[SqliteService.columnKategoriZakat] ?? 'Fitrah';
            final double jumlah = tx[SqliteService.columnJumlah] ?? 0.0;
            final String satuan = tx[SqliteService.columnTipeSatuan] ?? 'uang';
            final String displayJumlah = (satuan == 'beras')
                ? '${jumlah.toStringAsFixed(1)} Kg'
                : currencyFormat.format(jumlah);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SoftSurfaceCard(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.softSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getKategoriIcon(kategori),
                        size: 20,
                        color: AppColors.emeraldDeep,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nama,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Zakat $kategori',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
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
            );
          }),
      ],
    );
  }
}

class _ProfileTabContent extends StatefulWidget {
  final String username;
  final String? email;
  final int totalMuzakkiCount;
  final Future<void> Function() onLogout;
  final Future<void> Function() onDeleteAccount;
  final Function(String) onUpdateProfile;
  const _ProfileTabContent({
    required this.username,
    required this.email,
    required this.totalMuzakkiCount,
    required this.onLogout,
    required this.onDeleteAccount,
    required this.onUpdateProfile,
  });
  @override
  State<_ProfileTabContent> createState() => _ProfileTabContentState();
}

class _ProfileTabContentState extends State<_ProfileTabContent> {
  bool _working = false;

  void _showDeleteModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Hapus Akun Permanen?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tindakan ini tidak bisa dibatalkan. Seluruh data lokal Anda akan dibersihkan.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      widget.onDeleteAccount();
                    },
                    child: const Text(
                      'Hapus',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    IconData icon,
    Color iconColor,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.emeraldDeep, AppColors.emerald],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.emerald.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                child: const Icon(
                  Icons.badge_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amil Terverifikasi',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.email ?? 'amil@amiltrack.com',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Statistik Personal',
            style: TextStyle(
              color: AppColors.emeraldDeep,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SoftSurfaceCard(
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.orangeGold.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.how_to_reg_rounded,
                  color: AppColors.orangeGold,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.totalMuzakkiCount} Jiwa',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Total Muzakki Terlayani',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Pengaturan & Bantuan',
            style: TextStyle(
              color: AppColors.emeraldDeep,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SoftSurfaceCard(
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildMenuTile(
                Icons.edit_document,
                Colors.blue.shade700,
                'Edit Data Profil',
                'Perbarui nama identitas amil Anda',
                () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => _EditProfileModal(
                      currentName: widget.username,
                      onSave: widget.onUpdateProfile,
                    ),
                  );
                },
              ),
              const Divider(height: 1, color: Colors.black12),
              _buildMenuTile(
                Icons.support_agent_rounded,
                Colors.indigo,
                'Hotline Dewan Syariah',
                'Konsultasi kasus fikih via WhatsApp',
                () => _launchWithConfirmation(
                  context,
                  'https://wa.me/628123456789?text=Assalamu%27alaikum...',
                  'Buka WhatsApp',
                  'Anda akan dialihkan ke WhatsApp untuk chat dengan Hotline Syariat. Lanjutkan?',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          icon: const Icon(Icons.logout_rounded),
          label: const Text(
            'Logout Sistem',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            backgroundColor: AppColors.emerald,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: _working
              ? null
              : () async {
                  setState(() => _working = true);
                  try {
                    await widget.onLogout();
                  } finally {
                    if (mounted) setState(() => _working = false);
                  }
                },
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.delete_forever_rounded),
          label: const Text(
            'Hapus Akun Permanen',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            foregroundColor: Colors.red.shade700,
            side: BorderSide(color: Colors.red.shade200),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: _working ? null : _showDeleteModal,
        ),
      ],
    );
  }
}

class _EditProfileModal extends StatefulWidget {
  final String currentName;
  final Function(String) onSave;
  const _EditProfileModal({required this.currentName, required this.onSave});

  @override
  State<_EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<_EditProfileModal> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassContainer(
        width: double.infinity,
        borderRadius: 28,
        padding: const EdgeInsets.all(28),
        backgroundColor: AppColors.emeraldDeep.withValues(alpha: 0.85),
        glassOpacity: 0.9,
        blur: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Edit Data Profil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Text(
              'Perbarui informasi identitas amil Anda',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              decoration: InputDecoration(
                labelText: 'Nama Lengkap Baru',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.gold,
                ),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: AppColors.gold,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orangeGold,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () {
                final newName = _nameController.text.trim();
                if (newName.isNotEmpty) {
                  widget.onSave(newName);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profil berhasil diperbarui!'),
                      backgroundColor: AppColors.emerald,
                    ),
                  );
                }
              },
              child: const Text(
                'Simpan Perubahan',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NisabModal extends StatelessWidget {
  const _NisabModal();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassContainer(
        width: double.infinity,
        borderRadius: 28,
        padding: const EdgeInsets.all(28),
        backgroundColor: AppColors.emeraldDeep.withValues(alpha: 0.85),
        glassOpacity: 0.9,
        blur: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Informasi Nisab & Ketetapan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Text(
              'Standar acuan yang berlaku saat ini',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Zakat Fitrah', 'Rp 40.000 / 2.5 Kg'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Colors.white12, height: 1),
                  ),
                  _buildInfoRow('Zakat Profesi', 'Rp 6.859.394 / Bln'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Colors.white12, height: 1),
                  ),
                  _buildInfoRow('Zakat Maal', 'Rp 82.312.725 / Thn'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Colors.white12, height: 1),
                  ),
                  _buildInfoRow('Fidyah', 'Rp 60.000 / Hari'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Tutup',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.gold,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _RekapHarianModal extends StatelessWidget {
  final int muzakki;
  final double uang;
  const _RekapHarianModal({required this.muzakki, required this.uang});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      borderRadius: 28,
      padding: const EdgeInsets.all(28),
      backgroundColor: AppColors.emeraldDeep.withValues(alpha: 0.85),
      glassOpacity: 0.9,
      blur: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Rekapitulasi Hari Ini',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Total perolehan selama Anda bertugas hari ini.',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Muzakki',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$muzakki Jiwa',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white12, height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Dana Terhimpun',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(uang),
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.send_rounded, size: 20),
            label: const Text(
              'Kirim Laporan ke WhatsApp',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              _launchWithConfirmation(
                context,
                'https://wa.me/?text=Laporan%20Rekap%20Harian%0AMuzakki:%20$muzakki%20Jiwa%0ADana:%20Rp%20$uang',
                'Bagikan via WhatsApp',
                'Buka WhatsApp untuk membagikan laporan singkat ini ke Koordinator?',
              );
            },
          ),
        ],
      ),
    );
  }
}
