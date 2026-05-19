import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../services/sqlite_service.dart';
import 'soft_surface_card.dart';

class TransactionItemCard extends StatelessWidget {
  final Map<String, dynamic> tx;
  final Function(Map<String, dynamic>, String) onLongPress;
  final int index;

  const TransactionItemCard({
    super.key,
    required this.tx,
    required this.onLongPress,
    required this.index,
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
    final String nama = tx[SqliteService.columnNamaMuzakki] ?? 'Hamba Allah';
    final String kategori = tx[SqliteService.columnKategoriZakat] ?? 'Fitrah';
    final String satuan = tx[SqliteService.columnTipeSatuan] ?? 'uang';
    final String rawDate =
        tx[SqliteService.columnCreatedAt] ?? DateTime.now().toIso8601String();
    final double jumlah =
        (tx[SqliteService.columnJumlah] as num?)?.toDouble() ?? 0.0;

    String displayDate = '';
    try {
      displayDate = DateFormat(
        'dd/MM/yyyy • HH:mm',
      ).format(DateTime.parse(rawDate));
    } catch (_) {}
    final String displayJumlah = (satuan == 'beras')
        ? '${jumlah.toStringAsFixed(1)} Kg'
        : currencyFormat.format(jumlah);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftSurfaceCard(
        backgroundColor: Colors.white,
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onLongPress: () => onLongPress(tx, nama),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.softSurface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getKategoriIcon(kategori),
                      size: 22,
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
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Zakat $kategori • $displayDate',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        displayJumlah,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: AppColors.emeraldDeep,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 11,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'WA Struk',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
