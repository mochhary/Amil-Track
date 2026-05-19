import 'dart:io';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../core/constants.dart';
// soft surface and glass widgets moved to sliced widget file; import when needed in widgets
import '../widgets/app_watermark_background.dart';
import '../widgets/profile_tab_content.dart';
import 'transaction_form.dart';
import 'transaction_list.dart';
import '../services/auth_service.dart';
import '../services/sqlite_service.dart';
import '../services/sync_service.dart';

// TIGA WIDGET SLICING KITA
import '../widgets/hero_dashboard_card.dart';
import '../widgets/action_grid.dart';
import '../widgets/activity_feed.dart';

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

// moved launch helper into sliced widget file

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
  late String _currentUsername;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _toolsKey = GlobalKey();
  final GlobalKey _chartKey = GlobalKey();
  final GlobalKey _navKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();
  bool _hasShownTutorial = false;

  @override
  void initState() {
    super.initState();
    _currentUsername = widget.username;
    _loadAndCheckTutorial();
    _initialMagicSync();

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.contains(ConnectivityResult.none)) {
        if (_isOnline && mounted) {
          setState(() => _isOnline = false);
        }
      } else {
        _backgroundSync();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _loadAndCheckTutorial() {
    _dashboardFuture = _loadDashboardData();
    _dashboardFuture.then((data) {
      final int totalSemua =
          data.countFitrah +
          data.countProfesi +
          data.countMaal +
          data.countFidyah;
      if (totalSemua == 0 && !_hasShownTutorial && mounted) {
        _hasShownTutorial = true;
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted && _selectedTab == 0) {
            _showTutorial();
          }
        });
      }
    });
  }

  void _showTutorial() {
    TutorialCoachMark(
      targets: _createTutorialTargets(),
      colorShadow: AppColors.emeraldDeep,
      textSkip: "LEWATI",
      paddingFocus: 10.0,
      opacityShadow: 0.88,
      onFinish: () {},
      onClickTarget: (target) {},
      onClickOverlay: (target) {},
      onSkip: () => true,
    ).show(context: context);
  }

  List<TargetFocus> _createTutorialTargets() {
    return [
      TargetFocus(
        identify: "heroKey",
        keyTarget: _heroKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 24.0,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "1. Ringkasan Saldo",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Ini adalah kartu saldo utama Anda. Anda bisa MENGGESER kartu ini ke kiri/kanan untuk melihat total perolehan spesifik dari setiap kategori Zakat.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "toolsKey",
        keyTarget: _toolsKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 24.0,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "2. Peralatan Pintar",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Gunakan menu ini untuk mengecek harga Nisab terkini, mengirim rekap harian ke koordinator, atau membaca panduan Fikih resmi BAZNAS.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "chartKey",
        keyTarget: _chartKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 16.0,
        paddingFocus: 4.0,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "3. Metrik Visual",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Pantau persentase sebaran penerimaan zakat secara sekilas melalui indikator warna ini. Bar warna akan otomatis menyesuaikan diri seiring bertambahnya data.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "navKey",
        keyTarget: _navKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 32.0,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "4. Profil & Pengaturan",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Beralih ke tab ini untuk mengelola akun Anda, mengubah nama identitas amil, and melihat total rekam jejak pengabdian secara personal.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "fabKey",
        keyTarget: _fabKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "5. Catat Setoran Zakat",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Tekan tombol ini setiap kali ada Muzakki yang menyerahkan Zakat/Fidyah. Mari kita mulai menggunakan Amil Track!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ];
  }

  Future<void> _initialMagicSync() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (mounted) setState(() => _isOnline = true);
        bool hasNewData = await SyncService.instance.autoSync();
        if (hasNewData && mounted) _refreshDashboard();
      }
    } catch (_) {
      if (mounted) setState(() => _isOnline = false);
    }
  }

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
        if (hasNewData && mounted) _refreshDashboard();
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

    return _DashboardData(
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
    final Size screenSize = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final double navBarHeight = 65.0;
    final double navBarBottomSpacing = 24.0 + bottomPadding;
    final double fabSize = 58.0;

    final double fabBottomPos =
        navBarBottomSpacing + (navBarHeight / 2) - (fabSize / 2) + 12.0;
    final double fabLeftPos = (screenSize.width / 2) - (fabSize / 2);

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
                            HeroDashboardCard(
                                  key: _heroKey,
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

                            // MEMANGGIL WIDGET ACTION GRID KITA
                            ActionGrid(
                              key: _toolsKey,
                              todayMuzakki: data.todayMuzakki,
                              todayUang: data.todayUang,
                            ),

                            const SizedBox(height: 24),
                            _DistributionMiniChart(
                              key: _chartKey,
                              fitrah: data.countFitrah,
                              profesi: data.countProfesi,
                              maal: data.countMaal,
                              fidyah: data.countFidyah,
                            ),
                            const SizedBox(height: 24),

                            // MEMANGGIL WIDGET ACTIVITY FEED KITA
                            ActivityFeed(
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
                          ProfileTabContent(
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
                            onShowTutorial: () {
                              setState(() => _selectedTab = 0);
                              Future.delayed(
                                const Duration(milliseconds: 300),
                                () {
                                  _showTutorial();
                                },
                              );
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
                  bottom: navBarBottomSpacing,
                  left: 20,
                  right: 20,
                  height: navBarHeight,
                  child: Container(
                    key: _navKey,
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
                              color: Colors.transparent,
                              notchRadius: 36.0,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: ClipPath(
                            clipper: _NotchedRectangleClipper(
                              radius: 32.0,
                              notchRadius: 36.0,
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 30.0,
                                sigmaY: 30.0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.45),
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
                  bottom: fabBottomPos,
                  left: fabLeftPos,
                  child: Center(
                    child: Container(
                      key: _fabKey,
                      height: fabSize,
                      width: fabSize,
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

class _NotchedRectangleClipper extends CustomClipper<Path> {
  final double radius;
  final double notchRadius;

  _NotchedRectangleClipper({required this.radius, required this.notchRadius});

  @override
  Path getClip(Size size) {
    return _calculateNotchedPath(size, radius, notchRadius);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
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
    final path = _calculateNotchedPath(size, radius, notchRadius);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Path _calculateNotchedPath(Size size, double radius, double notchRadius) {
  final path = Path();
  final double w = size.width;
  final double h = size.height;

  final double center = w / 2;
  final double notchDepth = h * 0.72;
  final double curveSpread = notchRadius + (w * 0.02);
  final double bezierTension = w * 0.015;

  path.moveTo(radius, 0);
  path.lineTo(center - curveSpread, 0);
  path.cubicTo(
    center - notchRadius,
    0,
    center - notchRadius + bezierTension,
    notchDepth,
    center,
    notchDepth,
  );
  path.cubicTo(
    center + notchRadius - bezierTension,
    notchDepth,
    center + notchRadius,
    0,
    center + curveSpread,
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
  return path;
}

class _DistributionMiniChart extends StatelessWidget {
  final int fitrah;
  final int profesi;
  final int maal;
  final int fidyah;
  const _DistributionMiniChart({
    super.key,
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
