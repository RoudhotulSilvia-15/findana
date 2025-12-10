import 'package:intl/intl.dart';

enum TransactionType { income, expense }

enum TransactionCategory {
  salary('Gaji', TransactionType.income),
  bonus('Bonus', TransactionType.income),
  investment('Investasi', TransactionType.income),
  otherIncome('Lainnya', TransactionType.income),
  food('Makanan', TransactionType.expense),
  transport('Transportasi', TransactionType.expense),
  utilities('Listrik/Air', TransactionType.expense),
  entertainment('Hiburan', TransactionType.expense),
  shopping('Belanja', TransactionType.expense),
  health('Kesehatan', TransactionType.expense),
  education('Pendidikan', TransactionType.expense),
  otherExpense('Lainnya', TransactionType.expense);

  final String label;
  final TransactionType type;
  const TransactionCategory(this.label, this.type);
}

class Transaction {
  final String id;
  final double amount;
  final TransactionCategory category;
  final String description;
  final DateTime date;

  Transaction({
    String? id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  /// Format tanggal lokal (Indonesia)
  String get formattedDate {
    final formatter = DateFormat('dd MMM yyyy', 'id_ID');
    return formatter.format(date);
  }

  /// Waktu dalam format HH:mm
  String get formattedTime {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Jumlah dengan format Rp
  String get formattedAmount {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Copy dengan field tertentu berubah
  Transaction copyWith({
    String? id,
    double? amount,
    TransactionCategory? category,
    String? description,
    DateTime? date,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }
}
