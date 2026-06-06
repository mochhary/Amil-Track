import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/constants.dart';
import '../services/sqlite_service.dart';
import 'soft_surface_card.dart';

class ActivityFeed extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final VoidCallback onSeeAll;

  const ActivityFeed({
    super.key,
    required this.transactions,
    required this.onSeeAll,
  });

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
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final String nama =
                  tx[SqliteService.columnNamaMuzakki] ?? 'Hamba Allah';
              final String kategori =
                  tx[SqliteService.columnKategoriZakat] ?? 'Fitrah';
              final double jumlah =
                  (tx[SqliteService.columnJumlah] as num?)?.toDouble() ?? 0.0;
              final String satuan =
                  tx[SqliteService.columnTipeSatuan] ?? 'uang';
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                      // Flexible di sini untuk mencegah overflow angka yang sangat panjang
                      Flexible(
                        child: Text(
                          displayJumlah,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: AppColors.emeraldDeep,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
