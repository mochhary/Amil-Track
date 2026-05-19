import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../services/whatsapp_service.dart';

/// Shows WhatsApp receipt sending confirmation dialog
void showWhatsappReceiptDialog({
  required BuildContext context,
  required Map<String, dynamic> transaction,
  required String nama,
  required String amilName,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Kirim Kwitansi Digital',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: AppColors.emeraldDeep,
          fontSize: 16,
        ),
      ),
      content: Text(
        'Apakah Anda ingin mengirimkan berkas bukti terima zakat resmi ke WhatsApp atas nama $nama?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text(
            'Batal',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.emeraldDeep,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.pop(ctx);
            final Map<String, dynamic> txDataWithPhone = Map.from(transaction);
            if (txDataWithPhone['nomor_whatsapp'] == null) {
              txDataWithPhone['nomor_whatsapp'] = '081234567890';
            }
            WhatsappService.instance.sendKwitansi(
              transaction: txDataWithPhone,
              amilName: amilName,
              onError: (errorMsg) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMsg),
                    backgroundColor: Colors.red.shade800,
                  ),
                );
              },
            );
          },
          child: const Text(
            'Kirim Struk',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    ),
  );
}
