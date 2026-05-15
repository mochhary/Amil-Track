import 'package:flutter_test/flutter_test.dart';

import 'package:amil_track/services/transaction_schema.dart';

void main() {
  group('resolveTransactionColumns', () {
    test('prefers the actual transaction columns in order', () {
      final columns = <String>{
        'nama_muzakki',
        'jumlah_jiwa',
        'tipe_bayar',
        'total_bayar',
      };

      final selection = resolveTransactionColumns(columns);

      expect(selection.name, 'nama_muzakki');
      expect(selection.quantity, 'jumlah_jiwa');
      expect(selection.transactionType, 'tipe_bayar');
      expect(selection.amount, 'total_bayar');
      expect(selection.userId, null);
      expect(selection.phoneNumber, null);
      expect(selection.notes, null);
    });

    test('falls back to the first available match', () {
      final columns = <String>{
        'nama_muzakki',
        'jumlah',
        'jenis',
        'nominal_zakat_uang',
      };

      final selection = resolveTransactionColumns(columns);

      expect(selection.name, 'nama_muzakki');
      expect(selection.quantity, 'jumlah');
      expect(selection.transactionType, 'jenis');
      expect(selection.amount, 'nominal_zakat_uang');
    });
  });

  group('buildLegacyTransactionInsertPayload', () {
    test('builds payload with the actual backend columns', () {
      final payload = buildLegacyTransactionInsertPayload(
        muzakkiName: 'Hari',
        jumlahJiwa: 3,
        transactionType: 'uang',
        totalAmount: 150000,
      );

      expect(payload, {
        'nama_muzakki': 'Hari',
        'jumlah_jiwa': 3,
        'tipe_bayar': 'uang',
        'total_bayar': 150000,
      });
    });
  });

  group('extractTransactionAmount', () {
    test('reads numeric and string values from actual columns', () {
      expect(extractTransactionAmount({'total_bayar': 150000}), 150000);
      expect(extractTransactionAmount({'total_bayar': '30000'}), 30000);
    });

    test('returns zero when amount is missing', () {
      expect(extractTransactionAmount(<String, dynamic>{}), 0);
    });
  });

  group('extractTransactionType', () {
    test('reads the actual type column first', () {
      expect(extractTransactionType({'tipe_bayar': 'beras'}), 'beras');
    });

    test('returns null when type is missing', () {
      expect(extractTransactionType(<String, dynamic>{}), isNull);
    });
  });
}
