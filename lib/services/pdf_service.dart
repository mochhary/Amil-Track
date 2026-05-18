import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // FIX 1: Import kamus bahasa lokal
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<Uint8List> generateTransactionReport({
    required List<Map<String, dynamic>> transactions,
    required String amilName,
    required String filterName,
  }) async {
    // FIX 2: Menghidupkan mesin kalender Bahasa Indonesia sebelum membuat PDF
    await initializeDateFormatting('id_ID', null);

    final pdf = pw.Document();

    pw.ImageProvider? logoImage;
    try {
      logoImage = await imageFromAssetBundle(
        'assets/images/logo_amil_track.png',
      );
    } catch (e) {
      print('⚠️ Logo gagal dimuat ke PDF: $e');
    }

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Membuat Halaman Dokumen A4
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (context) => _buildHeader(logoImage, filterName),
        build: (context) => [
          pw.SizedBox(height: 24),
          _buildTable(transactions, currencyFormat),
          pw.SizedBox(height: 40),
          _buildFooter(amilName),
        ],
      ),
    );

    return pdf.save();
  }

  // KOMPONEN 1: KOP SURAT (HEADER)
  static pw.Widget _buildHeader(
    pw.ImageProvider? logoImage,
    String filterName,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            if (logoImage != null) ...[
              pw.Image(logoImage, width: 55, height: 55),
              pw.SizedBox(width: 16),
            ],
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'LEMBAGA AMIL ZAKAT',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'APLIKASI AMIL TRACK',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#064E3B'),
                  ),
                ),
                pw.Text(
                  'Laporan Resmi Penerimaan Zakat, Infaq, dan Fidyah',
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Divider(thickness: 2, color: PdfColor.fromHex('#064E3B')),
        pw.SizedBox(height: 8),
        pw.Text(
          'REKAPITULASI DATA: ${filterName.toUpperCase()}',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  // KOMPONEN 2: TABEL TRANSAKSI
  static pw.Widget _buildTable(
    List<Map<String, dynamic>> transactions,
    NumberFormat currencyFormat,
  ) {
    final headers = [
      'No',
      'Tanggal Waktu',
      'Nama Muzakki',
      'Kategori',
      'Jiwa',
      'Nominal',
    ];

    final data = List<List<String>>.generate(transactions.length, (index) {
      final tx = transactions[index];
      final dateStr = tx['created_at'] ?? '';
      String formattedDate = dateStr;
      try {
        formattedDate = DateFormat(
          'dd/MM/yyyy HH:mm',
        ).format(DateTime.parse(dateStr));
      } catch (_) {}

      final jumlah = (tx['jumlah'] as num?)?.toDouble() ?? 0.0;
      final satuan = tx['tipe_satuan'] ?? 'uang';
      final displayJumlah = satuan == 'beras'
          ? '${jumlah.toStringAsFixed(1)} Kg'
          : currencyFormat.format(jumlah);
      final jiwa = tx['jumlah_jiwa']?.toString() ?? '-';

      return [
        '${index + 1}',
        formattedDate,
        tx['nama_muzakki']?.toString() ?? 'Hamba Allah',
        tx['kategori_zakat']?.toString() ?? '-',
        jiwa,
        displayJumlah,
      ];
    });

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 10,
      ),
      headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#064E3B')),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
        5: pw.Alignment.centerRight,
      },
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
    );
  }

  // KOMPONEN 3: BAGIAN TANDA TANGAN (FOOTER)
  static pw.Widget _buildFooter(String amilName) {
    final dateNow = DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now());
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              'Dicetak pada: $dateNow',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 5),
            pw.Text('Amil Bertugas,', style: const pw.TextStyle(fontSize: 11)),
            pw.SizedBox(height: 50),
            pw.Text(
              amilName,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                decoration: pw.TextDecoration.underline,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
