import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  final List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  TransactionProvider() {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? transactionsJson = prefs.getString('transactions');
      
      if (transactionsJson != null) {
        final List<dynamic> decoded = json.decode(transactionsJson);
        _transactions.clear();
        _transactions.addAll(decoded.map((item) {
          if (item['type'] == 'Income') {
            return Income(
              title: item['title'],
              amount: item['amount'],
              date: DateTime.parse(item['date']),
            );
          } else {
            return Expense(
              title: item['title'],
              amount: item['amount'],
              date: DateTime.parse(item['date']),
            );
          }
        }).toList());
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    }
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> transactionsMap = _transactions.map((t) {
      return {
        'type': t.type,
        'title': t.title,
        'amount': t.amount,
        'date': t.date.toIso8601String(),
      };
    }).toList();
    await prefs.setString('transactions', json.encode(transactionsMap));
  }

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    _saveTransactions();
    notifyListeners();
  }

  void clearAllTransactions() {
    _transactions.clear();
    _saveTransactions();
    notifyListeners();
  }
}
