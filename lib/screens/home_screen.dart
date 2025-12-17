import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/financial_manager.dart';
import '../models/transaction.dart';
import 'input_income_screen.dart';
import 'input_expense_screen.dart';
import 'category_management.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final financialManager = Provider.of<FinancialManager>(context);

    // Format mata uang Rupiah
    final currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Keuangan'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const CategoryManagementScreen()),
              );
            },
            tooltip: 'Kelola Kategori',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Saldo Saat Ini
          Card(
            margin: const EdgeInsets.all(16.0),
            color: Colors.lightGreen[100],
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text('Saldo Saat Ini',
                      style: TextStyle(fontSize: 18, color: Colors.blueGrey)),
                  Text(
                    currencyFormatter.format(financialManager.balance),
                    style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: financialManager.balance >= 0 ? Colors.green : Colors.red),
                  ),
                ],
              ),
            ),
          ),

          // Daftar Transaksi Terbaru
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Transaksi Terbaru',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: financialManager.transactions.isEmpty
                ? const Center(child: Text('Belum ada transaksi.'))
                : ListView.builder(
                    itemCount: financialManager.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = financialManager.transactions[index];
                      final category = financialManager
                          .getCategoryById(transaction.categoryId);
                      final isIncome = transaction is Income;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              isIncome ? Colors.green : Colors.red,
                          child: Icon(
                            isIncome ? Icons.add : Icons.remove,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          transaction.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${category?.name ?? 'Tidak Ada Kategori'} - ${DateFormat('dd MMM yyyy').format(transaction.date)}',
                        ),
                        trailing: Text(
                          currencyFormatter.format(transaction.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isIncome ? Colors.green : Colors.red,
                          ),
                        ),
                        onLongPress: () => _confirmDelete(
                            context, transaction, financialManager),
                      );
                    },
                  ),
          ),
        ],
      ),
      // Tombol Floating Action untuk Tambah Transaksi
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton.extended(
            heroTag: "btn1",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const InputIncomeScreen()),
              );
            },
            label: const Text('Pemasukan'),
            icon: const Icon(Icons.add_to_photos),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: "btn2",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const InputExpenseScreen()),
              );
            },
            label: const Text('Pengeluaran'),
            icon: const Icon(Icons.remove_circle),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Transaction transaction,
      FinancialManager manager) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Transaksi'),
          content: Text(
              'Yakin ingin menghapus transaksi "${transaction.description}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                if (transaction.id != null) {
                  manager.deleteTransaction(transaction.id!);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}