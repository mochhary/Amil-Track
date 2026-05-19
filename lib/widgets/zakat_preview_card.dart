import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../core/constants.dart';

class ZakatPreviewCard extends StatelessWidget {
  final String selectedKategori;
  final String? tipeSatuanFitrah;
  final double calculatedJumlah;

  const ZakatPreviewCard({
    super.key,
    required this.selectedKategori,
    this.tipeSatuanFitrah,
    required this.calculatedJumlah,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.emeraldDeep, AppColors.emerald],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              selectedKategori == 'Fitrah' && tipeSatuanFitrah == 'beras'
                  ? Icons.rice_bowl_rounded
                  : Icons.auto_awesome_rounded,
              color: AppColors.gold,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LIVE PREVIEW WAJIB BAYAR',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  selectedKategori == 'Fitrah' && tipeSatuanFitrah == 'beras'
                      ? '${calculatedJumlah.toStringAsFixed(1)} Kg Beras'
                      : currencyFormat.format(calculatedJumlah),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    letterSpacing: -0.5,
                  ),
                ),
                if (selectedKategori == 'Profesi' &&
                    calculatedJumlah == 0.0) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Belum mencapai nisab harian/bulanan.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate(target: calculatedJumlah > 0 ? 1 : 0).shimmer(duration: 1200.ms);
  }
}
