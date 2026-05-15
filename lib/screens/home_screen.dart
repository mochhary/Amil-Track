import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../widgets/curved_bottom_navigation.dart';
import '../widgets/loading_states.dart';
import '../widgets/soft_surface_card.dart';
import 'transaction_form.dart';
import 'transaction_list.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.username});

  final String username;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_DashboardData> _dashboardFuture;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboardData();
  }

  void _refreshDashboard() {
    setState(() {
      _dashboardFuture = _loadDashboardData();
    });
  }

  Future<_DashboardData> _loadDashboardData() async {
    final rates = await SupabaseService.instance.getCurrentZakatRates();
    final totals = await SupabaseService.instance.fetchCollectedTotalsByType();

    return _DashboardData(
      zakatUangRate: rates[SupabaseService.zakatUangSettingKey],
      zakatBerasRate: rates[SupabaseService.zakatBerasSettingKey],
      totalUang: totals['uang'] ?? 0,
      totalBeras: totals['beras'] ?? 0,
    );
  }

  Future<void> _openSettingsDialog(_DashboardData currentData) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _NisabDialog(
        initialUang: currentData.zakatUangRate,
        initialBeras: currentData.zakatBerasRate,
      ),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {
        _dashboardFuture = _loadDashboardData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final username = widget.username;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_selectedTab == 0 ? 'Amil Track' : 'Profil'),
        actions: [
          if (_selectedTab == 0)
            IconButton(
              icon: const Icon(Icons.history_rounded),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TransactionListScreen(),
                  ),
                );
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: Container(
        height: 72,
        width: 72,
        margin: const EdgeInsets.only(top: 24),
        child: FloatingActionButton(
          elevation: 4,
          backgroundColor: AppColors.orangeGold,
          foregroundColor: AppColors.backgroundWhite,
          shape: const CircleBorder(),
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
            );
            if (result == true) {
              _refreshDashboard();
            }
          },
          child: const Icon(Icons.add_rounded, size: 36),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        notchMargin: 8,
        color: Colors.transparent,
        elevation: 0,
        child: SizedBox(
          height: 64,
          child: CurvedBottomNavigation(
            isHomeActive: _selectedTab == 0,
            isProfileActive: _selectedTab == 1,
            onHomeTap: () => setState(() => _selectedTab = 0),
            onProfileTap: () => setState(() => _selectedTab = 1),
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          FutureBuilder<_DashboardData>(
            future: _dashboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SkeletonDashboard();
              }

              final data = snapshot.data ?? const _DashboardData();

              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  110,
                ),
                children: [
                  _GreetingHeader(username: username),
                  const SizedBox(height: AppSpacing.lg),
                  _RateCard(
                    zakatUangRate: data.zakatUangRate,
                    zakatBerasRate: data.zakatBerasRate,
                    onEditPressed: () => _openSettingsDialog(data),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Total Uang',
                          value: SupabaseService.instance.formatCurrency(
                            data.totalUang,
                          ),
                          icon: Icons.account_balance_wallet_rounded,
                          accentColor: AppColors.orangeGold,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Total Beras',
                          value: '${data.totalBeras.toStringAsFixed(1)} Kg',
                          icon: Icons.rice_bowl_rounded,
                          accentColor: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          _ProfileTabContent(
            username: username,
            email: user?.email,
            onLogout: () async {
              await AuthService.instance.signOut();
            },
            onDeleteAccount: () async {
              await AuthService.instance.deleteAccount();
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileTabContent extends StatefulWidget {
  const _ProfileTabContent({
    required this.username,
    required this.email,
    required this.onLogout,
    required this.onDeleteAccount,
  });

  final String username;
  final String? email;
  final Future<void> Function() onLogout;
  final Future<void> Function() onDeleteAccount;

  @override
  State<_ProfileTabContent> createState() => _ProfileTabContentState();
}

class _ProfileTabContentState extends State<_ProfileTabContent> {
  bool _working = false;

  Future<void> _runGuarded(Future<void> Function() action) async {
    setState(() => _working = true);
    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Aksi gagal: $e')));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<bool?> _confirmAction({
    required String title,
    required String body,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        110,
      ),
      children: [
        SoftSurfaceCard(
          backgroundColor: AppColors.emerald,
          borderColor: AppColors.emerald,
          shadowColor: AppColors.shadowDark,
          highlightOpacity: 0.18,
          highlightAlignment: Alignment.topCenter,
          highlightRadius: 1.1,
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profil Amil',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.email ?? 'Tidak diketahui',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SoftSurfaceCard(
          backgroundColor: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Akun & Akses',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.emeraldDeep,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pengaturan, logout, dan penghapusan akun ada langsung di sini.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logout'),
                onPressed: _working
                    ? null
                    : () async {
                        final confirmed = await _confirmAction(
                          title: 'Keluar dari akun?',
                          body: 'Anda akan keluar dari perangkat ini.',
                          confirmLabel: 'Logout',
                        );
                        if (confirmed == true) {
                          await _runGuarded(widget.onLogout);
                        }
                      },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_forever_rounded),
                label: const Text('Hapus Akun'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade200),
                ),
                onPressed: _working
                    ? null
                    : () async {
                        final confirmed = await _confirmAction(
                          title: 'Hapus akun?',
                          body: 'Tindakan ini bersifat permanen.',
                          confirmLabel: 'Hapus',
                        );
                        if (confirmed == true) {
                          await _runGuarded(widget.onDeleteAccount);
                        }
                      },
              ),
            ],
          ),
        ),
        if (_working) ...[
          const SizedBox(height: AppSpacing.md),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return SoftSurfaceCard(
      backgroundColor: AppColors.emerald,
      borderColor: AppColors.emerald,
      shadowColor: AppColors.shadowDark,
      padding: const EdgeInsets.all(AppSpacing.lg),
      highlightOpacity: 0.18,
      highlightAlignment: Alignment.topCenter,
      highlightRadius: 1.1,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang,',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RateCard extends StatelessWidget {
  const _RateCard({
    required this.zakatUangRate,
    required this.zakatBerasRate,
    required this.onEditPressed,
  });

  final double? zakatUangRate;
  final double? zakatBerasRate;
  final VoidCallback onEditPressed;

  @override
  Widget build(BuildContext context) {
    return SoftSurfaceCard(
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nisab Zakat',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.emeraldDeep,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nilai terbaru tahun ini',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEditPressed,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.softSurface,
                ),
                icon: const Icon(Icons.edit_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _RateTile(
                  label: 'UANG',
                  icon: Icons.payments_rounded,
                  value: zakatUangRate == null
                      ? 'Belum diisi'
                      : 'Rp ${zakatUangRate!.toStringAsFixed(0)}',
                  subtitle: 'Nisab uang per jiwa',
                  color: AppColors.emerald,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _RateTile(
                  label: 'BERAS',
                  icon: Icons.rice_bowl_rounded,
                  value: zakatBerasRate == null
                      ? 'Belum diisi'
                      : '${zakatBerasRate!.toStringAsFixed(1)} Kg',
                  subtitle: 'Nisab beras per jiwa',
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RateTile extends StatelessWidget {
  const _RateTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final String label;
  final IconData icon;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.softSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return SoftSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: BorderRadius.circular(22),
      backgroundColor: Colors.white,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardData {
  const _DashboardData({
    this.zakatUangRate,
    this.zakatBerasRate,
    this.totalUang = 0,
    this.totalBeras = 0,
  });

  final double? zakatUangRate;
  final double? zakatBerasRate;
  final double totalUang;
  final double totalBeras;
}

class _NisabDialog extends StatefulWidget {
  const _NisabDialog({this.initialUang, this.initialBeras});

  final double? initialUang;
  final double? initialBeras;

  @override
  State<_NisabDialog> createState() => _NisabDialogState();
}

class _NisabDialogState extends State<_NisabDialog> {
  late final TextEditingController _uangController;
  late final TextEditingController _berasController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _uangController = TextEditingController(
      text: widget.initialUang?.toStringAsFixed(0) ?? '',
    );
    _berasController = TextEditingController(
      text: widget.initialBeras?.toStringAsFixed(1).replaceAll('.', ',') ?? '',
    );
  }

  @override
  void dispose() {
    _uangController.dispose();
    _berasController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await SupabaseService.instance.updateSettingValue(
        key: SupabaseService.zakatUangSettingKey,
        value: _uangController.text.trim(),
      );
      await SupabaseService.instance.updateSettingValue(
        key: SupabaseService.zakatBerasSettingKey,
        value: _berasController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Atur Nisab'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _uangController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Nisab Uang (Rp)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _berasController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Nisab Beras (Kg)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.of(context).pop(false);
                },
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _saving
              ? null
              : () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  _save();
                },
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan Nisab'),
        ),
      ],
    );
  }
}
