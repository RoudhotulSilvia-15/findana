// Abstract Class (ABSTRACTION)
abstract class Transaction {
  final String title;   
  final double amount;  
  final DateTime date;  

  Transaction({
    required this.title,
    required this.amount,
    required this.date,
  });

  String get type;
}

// INHERITANCE - Income mewarisi semua property dan method dari Transaction
class Income extends Transaction {
  Income({
    required super.title,   
    required super.amount,
    required super.date,
  });

  // POLYMORPHISM 
  @override
  String get type => "Income";
}

// INHERITANCE - Expense mewarisi semua property dan method dari Transaction
class Expense extends Transaction {
  Expense({
    required super.title,   
    required super.amount,
    required super.date,
  });

  // POLYMORPHISM 
  @override
  String get type => "Expense";
}
