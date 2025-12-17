import '../models/category.dart';
import '../models/transaction.dart';

abstract class DataService {
  // Category
  Future<void> initDB();
  Future<int> insertCategory(Category category);
  Future<List<Category>> getCategories(String type);
  Future<int> deleteCategory(int id);

  // Transaction
  Future<int> insertTransaction(Transaction transaction);
  Future<List<Transaction>> getAllTransactions();
  Future<List<Transaction>> getRecentTransactions();
  Future<int> deleteTransaction(int id);
}
