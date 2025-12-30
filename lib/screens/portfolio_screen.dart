import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/transaction_provider.dart';
import '../models/transaction.dart';
import '../utils.dart';
import 'package:intl/intl.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  Map<String, List<Transaction>> _groupByMonth(List<Transaction> transactions) {
    Map<String, List<Transaction>> grouped = {};
    for (var t in transactions) {
      String key = DateFormat('MMMM yyyy').format(t.date);
      (grouped[key] ??= []).add(t); 
    }
    return grouped;
  }

  Map<String, dynamic> _calculateStats(List<Transaction> transactions) {
    double income = 0, expense = 0;
    for (var t in transactions) {
      if (t.type == "Income") {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    return {'income': income, 'expense': expense, 'balance': income - expense, 'count': transactions.length};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f8),
      appBar: AppBar(
        backgroundColor: Colors.purple,
        elevation: 0,
        title: const Text("Portfolio Bulanan"),
        centerTitle: true,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          final transactions = provider.transactions;
          
          if (transactions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada data transaksi', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          final grouped = _groupByMonth(transactions);
          final sortedKeys = grouped.keys.toList()
            ..sort((a, b) => DateFormat('MMMM yyyy').parse(b).compareTo(DateFormat('MMMM yyyy').parse(a)));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedKeys.length,
            itemBuilder: (context, index) {
              final monthKey = sortedKeys[index];
              final monthTransactions = grouped[monthKey]!;
              final stats = _calculateStats(monthTransactions);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_month, color: Colors.purple, size: 28),
                  ),
                  title: Text(monthKey, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text('${stats['count']} transaksi', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatCurrency(stats['balance']),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: stats['balance'] >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        stats['balance'] >= 0 ? 'Surplus' : 'Defisit',
                        style: TextStyle(fontSize: 12, color: stats['balance'] >= 0 ? Colors.green : Colors.red),
                      ),
                    ],
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStat('Pemasukan', stats['income'], Colors.green, Icons.arrow_downward),
                              Container(width: 1, height: 40, color: Colors.grey.shade300),
                              _buildStat('Pengeluaran', stats['expense'], Colors.red, Icons.arrow_upward),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          ...monthTransactions.map((t) {
                            final isIncome = t.type == "Income";
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                    color: isIncome ? Colors.green : Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(t.title, style: const TextStyle(fontSize: 14))),
                                  Text(
                                    (isIncome ? '+ ' : '- ') + formatCurrency(t.amount),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isIncome ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStat(String label, double amount, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(formatCurrency(amount), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      ],
    );
  }
}
