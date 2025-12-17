import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/financial_manager.dart';
import '../models/category.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _categoryNameController = TextEditingController();
  String _selectedType = 'Income'; // Default tab

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedType = _tabController.index == 0 ? 'Income' : 'Expense';
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _categoryNameController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog(FinancialManager manager) {
    _categoryNameController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Kategori $_selectedType'),
          content: TextField(
            controller: _categoryNameController,
            decoration: const InputDecoration(hintText: "Nama Kategori"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Simpan'),
              onPressed: () {
                if (_categoryNameController.text.isNotEmpty) {
                  final newCategory = Category(
                    name: _categoryNameController.text.trim(),
                    type: _selectedType,
                  );
                  manager.addCategory(newCategory);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
  
  void _confirmDelete(BuildContext context, Category category,
      FinancialManager manager) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Kategori'),
          content: Text(
              'Yakin ingin menghapus kategori "${category.name}"? Menghapus kategori juga akan menghapus semua transaksi terkait.'),
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
                if (category.id != null) {
                  manager.deleteCategory(category.id!, category.type);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final financialManager = Provider.of<FinancialManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Kategori'),
        backgroundColor: Colors.blueGrey,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pemasukan', icon: Icon(Icons.arrow_upward)),
            Tab(text: 'Pengeluaran', icon: Icon(Icons.arrow_downward)),
          ],
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList(financialManager.incomeCategories, financialManager),
          _buildCategoryList(
              financialManager.expenseCategories, financialManager),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(financialManager),
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryList(
      List<Category> categories, FinancialManager manager) {
    return categories.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('Belum ada kategori $_selectedType. Silahkan tambahkan dengan menekan tombol (+) di bawah.'),
            ),
          )
        : ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                title: Text(category.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context, category, manager),
                ),
              );
            },
          );
  }
}