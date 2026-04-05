import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String _search = '';
  String _filterCategory = 'All';

  final List<String> _categories = [
    'All', 'Roofing', 'Structural', 'Ceiling', 'Decking', 'Accessories'
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await ApiService.getProducts();
      setState(() { _products = products; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack('Failed to load products. Is the server running?', isError: true);
    }
  }

  List<Product> get _filtered {
    return _products.where((p) {
      final matchSearch = _search.isEmpty ||
          p.name.toLowerCase().contains(_search.toLowerCase()) ||
          p.category.toLowerCase().contains(_search.toLowerCase());
      final matchCat =
          _filterCategory == 'All' || p.category == _filterCategory;
      return matchSearch && matchCat;
    }).toList();
  }

  Future<void> _navigateToForm({Product? product}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(product: product),
      ),
    );
    _loadProducts();
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('Delete Product'),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 14),
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(
                text: '"${product.name}"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '? This action cannot be undone.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.deleteProduct(product.id!);
        _showSnack('"${product.name}" deleted successfully');
        _loadProducts();
      } catch (e) {
        _showSnack('Failed to delete product', isError: true);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F4F8),
      child: Column(
        children: [
          _buildHeader(),
          _buildToolbar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Products',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1B2A))),
              const SizedBox(height: 2),
              Text('${_products.length} products in catalog',
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _navigateToForm(),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          // Search
          SizedBox(
            width: 280,
            child: TextField(
              onChanged: (val) => setState(() => _search = val),
              decoration: InputDecoration(
                hintText: 'Search by name or category...',
                hintStyle: const TextStyle(fontSize: 13),
                prefixIcon:
                    const Icon(Icons.search, size: 20, color: Colors.grey),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: true,
                fillColor: const Color(0xFFF8FAFB),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Category filter
          DropdownButton<String>(
            value: _filterCategory,
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(8),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (val) => setState(() => _filterCategory = val!),
            style: const TextStyle(color: Color(0xFF374151), fontSize: 13),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _loadProducts,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Refresh'),
            style:
                TextButton.styleFrom(foregroundColor: const Color(0xFF1565C0)),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    final items = _filtered;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              _search.isNotEmpty || _filterCategory != 'All'
                  ? 'No products match your search.'
                  : 'No products yet. Click "Add Product" to get started.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor:
                WidgetStateProperty.all(const Color(0xFFF8FAFB)),
            headingTextStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF374151)),
            dataTextStyle: const TextStyle(
                fontSize: 13, color: Color(0xFF111827)),
            columnSpacing: 32,
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Product Name')),
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Stock')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: items.map((p) {
              final isOut = p.stock == 0;
              final isLow = p.stock > 0 && p.stock <= 10;
              return DataRow(
                cells: [
                  DataCell(Text('#${p.id}',
                      style: const TextStyle(color: Colors.grey))),
                  DataCell(Text(p.name,
                      style: const TextStyle(fontWeight: FontWeight.w500))),
                  DataCell(_categoryChip(p.category)),
                  DataCell(Text('₱${p.price.toStringAsFixed(2)}')),
                  DataCell(Text('${p.stock}')),
                  DataCell(_statusChip(isOut, isLow)),
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: 'Edit',
                        child: IconButton(
                          icon: const Icon(Icons.edit_rounded,
                              color: Color(0xFF1565C0), size: 18),
                          onPressed: () => _navigateToForm(product: p),
                        ),
                      ),
                      Tooltip(
                        message: 'Delete',
                        child: IconButton(
                          icon: const Icon(Icons.delete_rounded,
                              color: Colors.redAccent, size: 18),
                          onPressed: () => _deleteProduct(p),
                        ),
                      ),
                    ],
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(category,
          style: const TextStyle(
              color: Color(0xFF1565C0),
              fontSize: 12,
              fontWeight: FontWeight.w500)),
    );
  }

  Widget _statusChip(bool isOut, bool isLow) {
    final color = isOut
        ? const Color(0xFFC62828)
        : isLow
            ? const Color(0xFFF57C00)
            : const Color(0xFF2E7D32);
    final bg = isOut
        ? const Color(0xFFFFEBEE)
        : isLow
            ? const Color(0xFFFFF8E1)
            : const Color(0xFFE8F5E9);
    final label = isOut ? 'Out of Stock' : isLow ? 'Low Stock' : 'In Stock';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}
