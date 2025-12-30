import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../provider/transaction_provider.dart';
import '../utils.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  
  double _computeBalance(List<Transaction> transactions) {
    double total = 0;
    for (var t in transactions) {
      total += t.type == "Income" ? t.amount : -t.amount;
    }
    return total;
  }

 
  double _computeIncome(List<Transaction> transactions) =>
      transactions.where((t) => t.type == "Income").fold(0.0, (sum, t) => sum + t.amount);

 
  double _computeExpense(List<Transaction> transactions) =>
      transactions.where((t) => t.type == "Expense").fold(0.0, (sum, t) => sum + t.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f8),
      appBar: AppBar(
        backgroundColor: Colors.purple,
        elevation: 0,
        title: const Text("Catatan Keuangan Harian"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            tooltip: 'Portfolio Bulanan',
            onPressed: () => Navigator.pushNamed(context, '/portfolio'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false),
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          final transactions = provider.transactions;
          final income = _computeIncome(transactions);
          final expense = _computeExpense(transactions);
          final balance = _computeBalance(transactions);

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.purple,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummary("Pemasukan", income, Colors.green),
                      _buildSummary("Pengeluaran", expense, Colors.red),
                      _buildSummary("Balance", balance, balance >= 0 ? Colors.purple : Colors.red),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: transactions.isEmpty
                    ? const Center(child: Text('Belum ada transaksi', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final t = transactions[index];
                          final isIncome = t.type == "Income";
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
                                child: Icon(
                                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: isIncome ? Colors.green : Colors.red,
                                ),
                              ),
                              title: Text(t.title),
                              subtitle: Text(t.date.toString().split(' ')[0], style: const TextStyle(fontSize: 12)),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    (isIncome ? "+ " : "- ") + formatCurrency(t.amount),
                                    style: TextStyle(
                                      color: isIncome ? Colors.green : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isIncome ? Colors.green.shade100 : Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isIncome ? "Pemasukan" : "Pengeluaran",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isIncome ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
      ),
    );
  }

  Widget _buildSummary(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 6),
        Text(formatCurrency(amount), style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12)),
      ],
    );
  }
}
