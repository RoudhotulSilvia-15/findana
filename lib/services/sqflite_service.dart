import 'package:sqflite/sqflite.dart' as sqf;
import 'package:path/path.dart'; 

import 'data_service.dart';
import '../models/category.dart';
import '../models/transaction.dart';

class SqfliteService implements DataService {
  static sqf.Database? _database;

  Future<sqf.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<sqf.Database> _initDB() async {
    String path = join(await sqf.getDatabasesPath(), 'findana.db');
    return await sqf.openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(sqf.Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        categoryId INTEGER NOT NULL,
        type TEXT NOT NULL
      )
    ''');
  }

  @override
  Future<void> initDB() async {
    await database;
  }

  @override
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  @override
  Future<List<Category>> getCategories(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  @override
  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');
    List<Transaction> transactions = [];
    for (var map in maps) {
      if (map['type'] == 'Income') {
        transactions.add(Income.fromMap(map));
      } else {
        transactions.add(Expense.fromMap(map));
      }
    }
    return transactions;
  }

  @override
  Future<List<Transaction>> getRecentTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
      limit: 10,
    );
    List<Transaction> transactions = [];
    for (var map in maps) {
      if (map['type'] == 'Income') {
        transactions.add(Income.fromMap(map));
      } else {
        transactions.add(Expense.fromMap(map));
      }
    }
    return transactions;
  }

  @override
  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
