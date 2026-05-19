import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../core/constants.dart';
import '../services/pdf_service.dart';

class ExportDocumentModal extends StatelessWidget {
  final List<Map<String, dynamic>> filteredList;
  final String selectedFilter;
  final DateTimeRange? selectedDateRange;

  const ExportDocumentModal({
    super.key,
    required this.filteredList,
    required this.selectedFilter,
    required this.selectedDateRange,
  });

  @override
  Widget build(BuildContext context) {
    final String labelTanggal = selectedDateRange == null
        ? 'Semua Waktu'
        : '${DateFormat('dd/MM/yy').format(selectedDateRange!.start)} s.d ${DateFormat('dd/MM/yy').format(selectedDateRange!.end)}';
    final String docName = 'Laporan_Zakat_${selectedFilter}_$labelTanggal.pdf';

    return Padding(
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
                color: AppColors.emerald.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.print_rounded, color: AppColors.emerald),
            ),
            title: const Text(
              'Cetak Laporan Fisik',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            onTap: () async {
              Navigator.pop(context);
              final pdfBytes = await PdfService.generateTransactionReport(
                transactions: filteredList,
                amilName: 'Mochammad Hari Fitrian',
                filterName: '$selectedFilter ($labelTanggal)',
              );
              await Printing.layoutPdf(
                onLayout: (format) async => pdfBytes,
                name: docName,
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.share_rounded, color: Colors.blue),
            ),
            title: const Text(
              'Bagikan File PDF Resmi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            onTap: () async {
              Navigator.pop(context);
              final pdfBytes = await PdfService.generateTransactionReport(
                transactions: filteredList,
                amilName: 'Mochammad Hari Fitrian',
                filterName: '$selectedFilter ($labelTanggal)',
              );
              await Printing.sharePdf(bytes: pdfBytes, filename: docName);
            },
          ),
        ],
      ),
    );
  }
}
