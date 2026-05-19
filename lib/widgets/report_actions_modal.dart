import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../core/constants.dart';
import '../services/pdf_service.dart';

/// Shows print and share options for transaction report PDF
Future<void> showReportActionsModal({
  required BuildContext context,
  required List<Map<String, dynamic>> filteredTransactions,
  required String selectedFilter,
  required DateTimeRange? selectedDateRange,
  required String amilName,
}) async {
  final String labelTanggal = selectedDateRange == null
      ? 'Semua Waktu'
      : '${DateFormat('dd/MM/yy').format(selectedDateRange.start)} s.d ${DateFormat('dd/MM/yy').format(selectedDateRange.end)}';

  final String docName = 'Laporan_Zakat_${selectedFilter}_$labelTanggal.pdf';

  if (!context.mounted) return;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Opsi Dokumen Administratif',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: AppColors.emeraldDeep,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'File: $docName',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.emerald.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.print_rounded, color: AppColors.emerald),
            ),
            title: const Text(
              'Cetak Laporan Fisik',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: const Text(
              'Hubungkan ke Printer Jaringan WiFi atau Bluetooth',
              style: TextStyle(fontSize: 11),
            ),
            onTap: () async {
              Navigator.pop(ctx);
              final pdfBytes = await PdfService.generateTransactionReport(
                transactions: filteredTransactions,
                amilName: amilName,
                filterName: '$selectedFilter ($labelTanggal)',
              );
              await Printing.layoutPdf(
                onLayout: (format) async => pdfBytes,
                name: docName,
              );
            },
          ),
          const Divider(height: 16),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.share_rounded, color: Colors.blue),
            ),
            title: const Text(
              'Bagikan File PDF Resmi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: const Text(
              'Kirim berkas digital laporan ke WhatsApp DKM / BAZNAS',
              style: TextStyle(fontSize: 11),
            ),
            onTap: () async {
              Navigator.pop(ctx);
              final pdfBytes = await PdfService.generateTransactionReport(
                transactions: filteredTransactions,
                amilName: amilName,
                filterName: '$selectedFilter ($labelTanggal)',
              );
              await Printing.sharePdf(bytes: pdfBytes, filename: docName);
            },
          ),
        ],
      ),
    ),
  );
}
