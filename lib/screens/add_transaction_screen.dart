import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/transaction_provider.dart';
import '../models/transaction.dart';
import '../utils.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  String selectedType = "Expense";

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    if (titleController.text.isEmpty) {
      showSnackBar(context, 'Deskripsi tidak boleh kosong!', isError: true);
      return;
    }
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      showSnackBar(context, 'Masukkan jumlah yang valid!', isError: true);
      return;
    }

    final transaction = selectedType == "Income"
        ? Income(title: titleController.text, amount: amount, date: DateTime.now())
        : Expense(title: titleController.text, amount: amount, date: DateTime.now());

    Provider.of<TransactionProvider>(context, listen: false).addTransaction(transaction);
    showSnackBar(context, 'Transaksi berhasil ditambahkan!');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = selectedType == "Income";
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f8),
      appBar: AppBar(
        backgroundColor: Colors.purple,
        elevation: 0,
        title: const Text("Tambah Transaksi"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isIncome ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Tipe: ${isIncome ? "PEMASUKAN" : "PENGELUARAN"}',
                style: TextStyle(fontWeight: FontWeight.bold, color: isIncome ? Colors.green : Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),

            // Type Selector
            Row(
              children: [
                _buildTypeButton(true, "Pemasukan", Icons.arrow_downward),
                const SizedBox(width: 16),
                _buildTypeButton(false, "Pengeluaran", Icons.arrow_upward),
              ],
            ),
            const SizedBox(height: 24),

            // Title
            const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: _inputDecoration('Contoh: Gaji, Belanja, dll'),
            ),
            const SizedBox(height: 16),

            // Amount
            const Text('Jumlah (Rp)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              decoration: _inputDecoration('Contoh: 100000'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Simpan Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(bool isIncomeType, String label, IconData icon) {
    final isSelected = isIncomeType ? selectedType == "Income" : selectedType == "Expense";
    final color = isIncomeType ? Colors.green : Colors.red;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedType = isIncomeType ? "Income" : "Expense"),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? color.shade100 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, size: 40, color: isSelected ? color : Colors.grey),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? color : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.purple, width: 2),
      ),
    );
  }
}
