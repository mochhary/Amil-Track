import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/constants.dart';
import 'soft_surface_card.dart';

class TransactionListItem extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final String nama;
  final String kategori;
  final String displayDate;
  final String displayJumlah;
  final int index;
  final VoidCallback onLongPress;
  final IconData Function(String kategori) getKategoriIcon;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.nama,
    required this.kategori,
    required this.displayDate,
    required this.displayJumlah,
    required this.index,
    required this.onLongPress,
    required this.getKategoriIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftSurfaceCard(
        backgroundColor: Colors.white,
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Petunjuk: Tahan lama (long press) untuk mengirim kwitansi WhatsApp',
                  ),
                  duration: Duration(seconds: 2),
                  backgroundColor: AppColors.emeraldDeep,
                ),
              );
            },
            onLongPress: onLongPress,
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
                      getKategoriIcon(kategori),
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
                            'WhatsApp Struk',
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
    ).animate().fade(duration: 200.ms, delay: (index * 40).ms).slideX(begin: 0.02);
  }
}
