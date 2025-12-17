abstract class Transaction {
  final int? id;
  final double amount;
  final DateTime date;
  final String description;
  final int categoryId;

  Transaction({
    this.id,
    required this.amount,
    required this.date,
    required this.description,
    required this.categoryId,
  });

  String get type;

  Map<String, dynamic> toMap();
}

class Income extends Transaction {
  Income({
    int? id,
    required double amount,
    required DateTime date,
    required String description,
    required int categoryId,
  }) : super(
          id: id,
          amount: amount,
          date: date,
          description: description,
          categoryId: categoryId,
        );

  @override
  String get type => 'Income';

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      description: map['description'],
      categoryId: map['categoryId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'categoryId': categoryId,
      'type': type,
    };
  }
}

class Expense extends Transaction {
  Expense({
    int? id,
    required double amount,
    required DateTime date,
    required String description,
    required int categoryId,
  }) : super(
          id: id,
          amount: amount,
          date: date,
          description: description,
          categoryId: categoryId,
        );

  @override
  String get type => 'Expense';

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      description: map['description'],
      categoryId: map['categoryId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'categoryId': categoryId,
      'type': type,
    };
  }
}
