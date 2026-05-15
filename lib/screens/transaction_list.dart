import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../services/supabase_service.dart';
import '../widgets/amil_track_logo.dart';
import '../widgets/soft_surface_card.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = SupabaseService.instance.fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Zakat')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _future = SupabaseService.instance.fetchTransactions();
          });
          await _future;
        },
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: SoftSurfaceCard(
                          backgroundColor: Colors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const AmilTrackLogo(size: 96, showTitle: false),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Data belum bisa dimuat',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: AppColors.emeraldDeep,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Silakan coba beberapa saat lagi.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: SoftSurfaceCard(
                          backgroundColor: Colors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const AmilTrackLogo(size: 96, showTitle: false),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Belum ada zakat',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: AppColors.emeraldDeep,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tambah zakat pertama untuk mulai melihat riwayat.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final t = items[index];
                final type = (t['tipe_bayar'] ?? t['transaction_type'] ?? '')
                    .toString();
                final amount = t['total_bayar'] ?? t['total_amount'];
                final title =
                    t['muzakki_name'] ??
                    t['nama_muzakki'] ??
                    t['name'] ??
                    t['nama'] ??
                    '—';
                final phone = (t['phone_number'] ?? '').toString();
                final createdAt = (t['created_at'] ?? '').toString();
                return SoftSurfaceCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  borderRadius: BorderRadius.circular(22),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: type == 'beras'
                            ? AppColors.gold.withValues(alpha: 0.14)
                            : AppColors.emerald.withValues(alpha: 0.12),
                        child: Icon(
                          type == 'beras'
                              ? Icons.rice_bowl_rounded
                              : Icons.payments_rounded,
                          color: type == 'beras'
                              ? AppColors.gold
                              : AppColors.emerald,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title.toString(),
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: AppColors.emeraldDeep,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              type.isEmpty
                                  ? 'Tidak diketahui'
                                  : type.toUpperCase(),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.8,
                                  ),
                            ),
                            if (phone.isNotEmpty || createdAt.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                [phone, createdAt]
                                    .where((value) => value.isNotEmpty)
                                    .join(' • '),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        SupabaseService.instance.formatCurrency(amount ?? 0),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.emeraldDeep,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
