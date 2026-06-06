import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsappService {
  WhatsappService._privateConstructor();
  static final WhatsappService instance = WhatsappService._privateConstructor();

  // ============================================================================
  // FUNGSI 1: PARSING & VALIDASI NOMOR HP (ROBUST ERROR HANDLING)
  // Mengubah format lokal (08xx) atau (+62xx) menjadi format internasional (62xx)
  // ============================================================================
  String? _parsePhoneNumber(String? phone) {
    if (phone == null || phone.trim().isEmpty || phone == 'null') return null;

    // Bersihkan semua karakter non-digital seperti spasi, strip, atau plus
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.startsWith('0')) {
      cleaned = '62${cleaned.substring(1)}';
    } else if (cleaned.startsWith('62')) {
      // Sudah dalam format internasional yang benar
    } else {
      if (cleaned.length < 9) return null;
      cleaned = '62$cleaned';
    }

    return cleaned;
  }

  // ============================================================================
  // FUNGSI 2: RICH TEXT TEMPLATE BUILDER & DEEP LINKING LAUNCHER
  // Merangkai pesan teks formal tanpa emoji dan meluncurkan URL wa.me
  // ============================================================================
  Future<void> sendKwitansi({
    required Map<String, dynamic> transaction,
    required String amilName,
    String? phone, // DITAMBAHKAN: Menerima passing langsung dari UI
    required Function(String errorMessage) onError,
  }) async {
    // Membaca kolom nomor telepon (prioritas dari parameter, lalu dari map)
    final String? rawPhone =
        phone ?? transaction['nomor_whatsapp'] ?? transaction['phone'];
    final String? validPhone = _parsePhoneNumber(rawPhone);

    // Proteksi 1: Validasi keberadaan nomor WhatsApp Muzakki
    if (validPhone == null) {
      onError(
        'Nomor WhatsApp Muzakki tidak ditemukan atau format tidak valid (Contoh: 081234xxx).',
      );
      return;
    }

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final String nama = transaction['nama_muzakki'] ?? 'Hamba Allah';
    final String kategori = transaction['kategori_zakat'] ?? 'Fitrah';
    final String satuan = transaction['tipe_satuan'] ?? 'uang';
    final double jumlah = (transaction['jumlah'] as num?)?.toDouble() ?? 0.0;
    final String jiwa = transaction['jumlah_jiwa']?.toString() ?? '-';
    final String rawDate =
        transaction['created_at'] ?? DateTime.now().toIso8601String();

    String formattedDate = rawDate;
    try {
      formattedDate = DateFormat(
        'dd MMMM yyyy HH:mm',
        'id_ID',
      ).format(DateTime.parse(rawDate));
    } catch (_) {}

    final String displayJumlah = (satuan == 'beras')
        ? '${jumlah.toStringAsFixed(1)} Kg Beras'
        : currencyFormat.format(jumlah);

    // Merangkai pesan teks formal dengan standar spasi dan penataan rapi baku
    final String message =
        '*BUKTI TERIMA ZAKAT DIGITAL*\n'
        '----------------------------------------\n\n'
        'Alhamdulillah, telah diterima pembayaran zakat dengan rincian sebagai berikut:\n\n'
        'Nama Muzakki: $nama\n'
        'Kategori Zakat: Zakat $kategori\n'
        'Jumlah Jiwa: $jiwa\n'
        'Total Pembayaran: $displayJumlah\n'
        'Tanggal Transaksi: $formattedDate\n'
        'Amil Bertugas: $amilName\n\n'
        '----------------------------------------\n'
        'Jazaakallahu khairan katsiran atas zakat yang Anda tunaikan. Semoga Allah SWT membersihkan harta Anda, menyucikan jiwa Anda, dan memberikan keberkahan yang melimpah untuk keluarga. Aamiin ya Rabbal Alamin.\n\n'
        'Salam, Pengurus DKM Masjid\n'
        'Aplikasi Amil Track';

    // Konversi string pesan menjadi format URL Safe (Percent-Encoding)
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$validPhone?text=${Uri.encodeComponent(message)}',
    );

    // Proteksi 2: Membuka deep link WhatsApp secara aman
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(whatsappUri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      onError(
        'Tidak dapat membuka aplikasi WhatsApp. Pastikan aplikasi WhatsApp telah terpasang pada perangkat Anda.',
      );
    }
  }
}
