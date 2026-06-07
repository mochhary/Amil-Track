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

    // Keamanan: Pastikan data jumlah adalah angka, jika tidak set 0
    final double jumlah = (tx[SqliteService.columnJumlah] is num)
        ? (tx[SqliteService.columnJumlah] as num).toDouble()
        : 0.0;

    // PERBAIKAN 12.14: Mengambil data nomor WA menggunakan kunci kolom yang benar dari SQLite/Supabase
    final String? phone =
        tx[SqliteService.columnNomorWhatsapp]?.toString() ??
        tx['phone']?.toString();
    final bool hasPhone =
        phone != null && phone.trim().isNotEmpty && phone != 'null';

    String displayDate = '';
    try {
      displayDate = DateFormat(
        'dd/MM/yyyy • HH:mm',
      ).format(DateTime.parse(rawDate));
    } catch (_) {
      displayDate = '-';
    }

    final String displayJumlah = (satuan == 'beras')
        ? '${jumlah.toStringAsFixed(1)} Kg'
        : currencyFormat.format(jumlah);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SoftSurfaceCard(
        backgroundColor: Colors.white,
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onLongPress: () {
              if (hasPhone) {
                // PERBAIKAN: Operator (!) memastikan variabel phone dijamin tidak null saat diserahkan ke Callback
                onLongPress(tx, phone!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Nomor WA Muzakki tidak tersedia.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors
                        .redAccent, // PERBAIKAN: Memberikan warna peringatan yang tegas
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.emeraldDeep.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getKategoriIcon(kategori),
                      size: 22,
                      color: AppColors.emeraldDeep,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Bagian Nama & Kategori (Dibatasi dengan Expanded)
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
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Zakat $kategori • $displayDate',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Bagian Harga & Tombol WA (Dibatasi dengan Flexible agar tidak overflow)
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          displayJumlah,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: AppColors.emeraldDeep,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Opacity(
                          opacity: hasPhone ? 1.0 : 0.3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: hasPhone
                                  ? AppColors.emerald.withOpacity(0.1)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chat_bubble_rounded,
                                  size: 9,
                                  color: hasPhone
                                      ? AppColors.emerald
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'WA',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: hasPhone
                                        ? AppColors.emerald
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
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
    );
  }
}
