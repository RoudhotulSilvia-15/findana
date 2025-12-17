import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../services/data_service.dart';
import '../services/sqflite_service.dart';

class FinancialManager extends ChangeNotifier {
  // Inisialisasi service yang digunakan
  final DataService _dataService = SqfliteService();

  List<Transaction> _transactions = [];
  List<Category> _incomeCategories = [];
  List<Category> _expenseCategories = [];
  double _balance = 0.0;

  List<Transaction> get transactions => _transactions;
  List<Category> get incomeCategories => _incomeCategories;
  List<Category> get expenseCategories => _expenseCategories;
  double get balance => _balance;

  FinancialManager() {
    initialize();
  }

  Future<void> initialize() async {
    await _dataService.initDB();
    await _loadData();
  }

  Future<void> _loadData() async {
    await _loadCategories();
    await _loadTransactions();
    _calculateBalance();
    notifyListeners();
  }

  Future<void> _loadCategories() async {
    _incomeCategories = await _dataService.getCategories('Income');
    _expenseCategories = await _dataService.getCategories('Expense');
  }

  Future<void> _loadTransactions() async {
    _transactions = await _dataService.getAllTransactions();
  }

  void _calculateBalance() {
    _balance = 0.0;
    for (var t in _transactions) {
      if (t is Income) {
        _balance += t.amount;
      } else if (t is Expense) {
        _balance -= t.amount;
      }
    }
  }

  // --- Category Management ---

  Future<void> addCategory(Category category) async {
    await _dataService.insertCategory(category);
    await _loadCategories();
    notifyListeners();
  }
  
  Future<void> deleteCategory(int id, String type) async {
    await _dataService.deleteCategory(id);
    await _loadData(); // Load data ulang karena saldo bisa berubah
    notifyListeners();
  }

  // --- Transaction Management ---

  Future<void> addTransaction(Transaction transaction) async {
    await _dataService.insertTransaction(transaction);
    await _loadData();
    notifyListeners();
  }
  
  Future<void> deleteTransaction(int id) async {
    await _dataService.deleteTransaction(id);
    await _loadData();
    notifyListeners();
  }

  Category? getCategoryById(int id) {
    try {
      return [..._incomeCategories, ..._expenseCategories]
          .firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}