class TransactionColumnSelection {
  const TransactionColumnSelection({
    required this.name,
    required this.quantity,
    required this.transactionType,
    required this.amount,
    required this.userId,
    required this.phoneNumber,
    required this.notes,
  });

  final String? name;
  final String? quantity;
  final String? transactionType;
  final String? amount;
  final String? userId;
  final String? phoneNumber;
  final String? notes;
}

const List<String> _nameCandidates = <String>['nama_muzakki', 'muzakki_name'];

const List<String> _quantityCandidates = <String>['jumlah_jiwa', 'jumlah'];

const List<String> _transactionTypeCandidates = <String>[
  'tipe_bayar',
  'transaction_type',
  'jenis',
  'type',
];

const List<String> _amountCandidates = <String>[
  'total_bayar',
  'total_amount',
  'nominal',
  'nominal_zakat',
  'nominal_amount',
  'nominal_zakat_uang',
  'total_uang',
  'jumlah_uang',
];

String? pickFirstMatchingColumn(Set<String> columns, List<String> candidates) {
  for (final candidate in candidates) {
    if (columns.contains(candidate)) {
      return candidate;
    }
  }

  return null;
}

TransactionColumnSelection resolveTransactionColumns(Set<String> columns) {
  return TransactionColumnSelection(
    name: pickFirstMatchingColumn(columns, _nameCandidates),
    quantity: pickFirstMatchingColumn(columns, _quantityCandidates),
    transactionType: pickFirstMatchingColumn(
      columns,
      _transactionTypeCandidates,
    ),
    amount: pickFirstMatchingColumn(columns, _amountCandidates),
    userId: null,
    phoneNumber: null,
    notes: null,
  );
}

Map<String, dynamic> buildTransactionInsertPayload({
  required TransactionColumnSelection columns,
  required String muzakkiName,
  required int jumlahJiwa,
  required String transactionType,
  required double totalAmount,
  String? userId,
  String? phoneNumber,
  String? notes,
}) {
  final payload = <String, dynamic>{};

  if (columns.name != null) {
    payload[columns.name!] = muzakkiName;
  }

  if (columns.quantity != null) {
    payload[columns.quantity!] = jumlahJiwa;
  }

  if (columns.transactionType != null) {
    payload[columns.transactionType!] = transactionType;
  }

  if (columns.amount != null) {
    payload[columns.amount!] = totalAmount;
  }

  if (columns.userId != null && userId != null && userId.isNotEmpty) {
    payload[columns.userId!] = userId;
  }

  if (columns.phoneNumber != null &&
      phoneNumber != null &&
      phoneNumber.isNotEmpty) {
    payload[columns.phoneNumber!] = phoneNumber;
  }

  if (columns.notes != null && notes != null && notes.isNotEmpty) {
    payload[columns.notes!] = notes;
  }

  return payload;
}

double extractTransactionAmount(Map<String, dynamic> row) {
  for (final candidate in _amountCandidates) {
    final value = row[candidate];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final parsed = double.tryParse(value.replaceAll(',', ''));
      if (parsed != null) {
        return parsed;
      }
    }
  }

  return 0.0;
}

String? extractTransactionType(Map<String, dynamic> row) {
  final candidates = <String>[
    'tipe_bayar',
    'transaction_type',
    'jenis',
    'type',
  ];

  for (final candidate in candidates) {
    final value = row[candidate];
    if (value != null) {
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
  }

  return null;
}

Map<String, dynamic> buildLegacyTransactionInsertPayload({
  required String muzakkiName,
  required int jumlahJiwa,
  required String transactionType,
  required double totalAmount,
}) {
  return <String, dynamic>{
    'nama_muzakki': muzakkiName,
    'jumlah_jiwa': jumlahJiwa,
    'tipe_bayar': transactionType,
    'total_bayar': totalAmount,
  };
}
