import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/transaction.dart';

class FinanceApp extends StatefulWidget {
  const FinanceApp({super.key});

  @override
  State<FinanceApp> createState() => _FinanceAppState();
}

class _FinanceAppState extends State<FinanceApp> with TickerProviderStateMixin {
  final List<Transaction> _transactions = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addTransaction(Transaction transaction) {
    setState(() {
      _transactions.insert(0, transaction);
    });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((t) => t.id == id);
    });
  }

  /// Hitung saldo total & ringkas per kategori
  Map<String, dynamic> _calculateSummary() {
    double totalIncome = 0, totalExpense = 0;
    for (final t in _transactions) {
      if (t.category.type == TransactionType.income) {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
      }
    }
    return {
      'income': totalIncome,
      'expense': totalExpense,
      'balance': totalIncome - totalExpense,
    };
  }

  /// Ringkas transaksi per bulan (untuk laporan bulanan)
  Map<String, double> _groupByMonth() {
    final result = <String, double>{};
    for (final t in _transactions) {
      final key = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
      if (!result.containsKey(key)) result[key] = 0;
      result[key] = result[key]! + (t.category.type == TransactionType.income ? t.amount : -t.amount);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Keuangan Harian'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.add_circle), text: 'Tambah'),
            Tab(icon: Icon(Icons.list), text: 'Daftar'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Laporan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAddTab(),
          _buildListTab(),
          _buildReportTab(),
        ],
      ),
    );
  }

  /// Tab 1: Tambah Transaksi
  Widget _buildAddTab() {
    return _AddTransactionForm(onAdd: _addTransaction);
  }

  /// Tab 2: Daftar Transaksi
  Widget _buildListTab() {
    final summary = _calculateSummary();
    return Column(
      children: [
        _buildSummaryCard(summary),
        Expanded(
          child: _transactions.isEmpty
              ? const Center(child: Text('Tidak ada transaksi. Mulai catat keuangan Anda.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final tx = _transactions[index];
                    return _buildTransactionTile(tx);
                  },
                ),
        ),
      ],
    );
  }

  /// Tab 3: Laporan Ringkas
  Widget _buildReportTab() {
    final monthlyData = _groupByMonth();
    final summary = _calculateSummary();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan Umum', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _summaryRow('Total Pemasukan', summary['income'], Colors.green),
                  _summaryRow('Total Pengeluaran', summary['expense'], Colors.red),
                  const Divider(),
                  _summaryRow(
                    'Saldo Akhir',
                    summary['balance'],
                    summary['balance'] >= 0 ? Colors.blue : Colors.orange,
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Ringkasan Per Bulan', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (monthlyData.isEmpty)
            const Text('Tidak ada data untuk ditampilkan.')
          else
            ...monthlyData.entries
                .map((e) {
                  final isPositive = e.value >= 0;
                  return Card(
                    child: ListTile(
                      title: Text(e.key),
                      trailing: Text(
                        'Rp ${e.value.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  );
                })
                .toList(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> summary) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _summaryRow('Pemasukan', summary['income'], Colors.green),
            _summaryRow('Pengeluaran', summary['expense'], Colors.red),
            const Divider(),
            _summaryRow(
              'Saldo',
              summary['balance'],
              summary['balance'] >= 0 ? Colors.blue : Colors.orange,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double amount, Color color, {bool isBold = false}) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            formatter.format(amount),
            style: TextStyle(color: color, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(Transaction tx) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Dismissible(
        key: ValueKey(tx.id),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) => _deleteTransaction(tx.id),
        child: ListTile(
          leading: Icon(
            tx.category.type == TransactionType.income ? Icons.add_circle : Icons.remove_circle,
            color: tx.category.type == TransactionType.income ? Colors.green : Colors.red,
          ),
          title: Text(tx.category.label),
          subtitle: Text('${tx.formattedDate} • ${tx.description}'),
          trailing: Text(
            tx.formattedAmount,
            style: TextStyle(
              color: tx.category.type == TransactionType.income ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddTransactionForm extends StatefulWidget {
  final Function(Transaction) onAdd;

  const _AddTransactionForm({required this.onAdd});

  @override
  State<_AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<_AddTransactionForm> {
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  TransactionType _selectedType = TransactionType.expense;
  TransactionCategory _selectedCategory = TransactionCategory.food;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    final amount = double.tryParse(_amountController.text);
    final desc = _descriptionController.text.trim();

    if (amount == null || amount <= 0 || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pastikan semua field terisi dengan benar')),
      );
      return;
    }

    final tx = Transaction(
      amount: amount,
      category: _selectedCategory,
      description: desc,
      date: _selectedDate,
    );

    widget.onAdd(tx);
    _amountController.clear();
    _descriptionController.clear();
    _selectedType = TransactionType.expense;
    _selectedCategory = TransactionCategory.food;
    _selectedDate = DateTime.now();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi berhasil ditambahkan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final incomeCats = TransactionCategory.values.where((c) => c.type == TransactionType.income).toList();
    final expenseCats = TransactionCategory.values.where((c) => c.type == TransactionType.expense).toList();
    final displayCats = _selectedType == TransactionType.income ? incomeCats : expenseCats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Tipe Transaksi
          SegmentedButton<TransactionType>(
            segments: const [
              ButtonSegment(label: Text('Pemasukan'), value: TransactionType.income),
              ButtonSegment(label: Text('Pengeluaran'), value: TransactionType.expense),
            ],
            selected: {_selectedType},
            onSelectionChanged: (newSelection) {
              setState(() {
                _selectedType = newSelection.first;
                _selectedCategory = _selectedType == TransactionType.income ? incomeCats.first : expenseCats.first;
              });
            },
          ),
          const SizedBox(height: 16),

          // Jumlah
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Jumlah (Rp)',
              border: OutlineInputBorder(),
              prefixText: 'Rp ',
            ),
          ),
          const SizedBox(height: 16),

          // Kategori
          DropdownButtonFormField<TransactionCategory>(
            initialValue: _selectedCategory,
            items: displayCats.map((cat) => DropdownMenuItem(value: cat, child: Text(cat.label))).toList(),
            onChanged: (newCat) {
              if (newCat != null) setState(() => _selectedCategory = newCat);
            },
            decoration: const InputDecoration(
              labelText: 'Kategori',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Deskripsi
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Keterangan',
              border: OutlineInputBorder(),
              hintText: 'mis: Beli makan siang',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // Tanggal
          Row(
            children: [
              Expanded(
                child: Text('Tanggal: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: const Text('Pilih'),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tombol Submit
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Simpan Transaksi'),
            onPressed: _submitForm,
          ),
        ],
      ),
    );
  }
}
