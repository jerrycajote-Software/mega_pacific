import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final products = await ApiService.getProducts();
      setState(() { _products = products; _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  // ── Computed Stats ──────────────────────────────
  int    get _totalProducts => _products.length;
  int    get _totalStock    => _products.fold(0, (s, p) => s + p.stock);
  double get _totalValue    => _products.fold(0.0, (s, p) => s + p.price * p.stock);
  int    get _outOfStock    => _products.where((p) => p.stock == 0).length;
  int    get _lowStock      => _products.where((p) => p.stock > 0 && p.stock <= 10).length;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F4F8),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildError()
                    : _buildBody(),
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1B2A))),
              SizedBox(height: 2),
              Text('Welcome back, Administrator',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _loadProducts,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Refresh'),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF1565C0)),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 56, color: Colors.redAccent),
          const SizedBox(height: 12),
          const Text('Could not connect to server',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Make sure your backend is running on localhost:3000',
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadProducts,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Stat Cards ──────────────────────────
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.6,
            children: [
              _StatCard(
                label: 'Total Products',
                value: '$_totalProducts',
                icon: Icons.inventory_2_rounded,
                color: const Color(0xFF1565C0),
                bg: const Color(0xFFE3F2FD),
              ),
              _StatCard(
                label: 'Total Stock',
                value: '$_totalStock units',
                icon: Icons.layers_rounded,
                color: const Color(0xFF00897B),
                bg: const Color(0xFFE0F2F1),
              ),
              _StatCard(
                label: 'Inventory Value',
                value: '₱${_formatNumber(_totalValue)}',
                icon: Icons.payments_rounded,
                color: const Color(0xFFF57C00),
                bg: const Color(0xFFFFF8E1),
              ),
              _StatCard(
                label: 'Out of Stock',
                value: '$_outOfStock items',
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFC62828),
                bg: const Color(0xFFFFEBEE),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Category Breakdown ──────────────────
          if (_products.isNotEmpty) ...[
            _buildSectionTitle('Stock by Category'),
            const SizedBox(height: 12),
            _buildCategoryBreakdown(),
            const SizedBox(height: 28),
          ],

          // ── Recent Products Table ───────────────
          _buildSectionTitle('Recent Products'),
          if (_lowStock > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Color(0xFFF57C00), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '$_lowStock product(s) are running low on stock.',
                    style: const TextStyle(
                        color: Color(0xFFF57C00), fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          _buildRecentTable(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D1B2A)));
  }

  Widget _buildCategoryBreakdown() {
    final Map<String, int> categoryStock = {};
    for (final p in _products) {
      categoryStock[p.category] = (categoryStock[p.category] ?? 0) + p.stock;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: categoryStock.entries.map((entry) {
          final maxStock = categoryStock.values
              .fold(0, (prev, v) => v > prev ? v : prev);
          final fraction = maxStock == 0 ? 0.0 : entry.value / maxStock;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                SizedBox(
                    width: 100,
                    child: Text(entry.key,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF374151)))),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF1565C0)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${entry.value}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF1565C0))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentTable() {
    if (_products.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: _cardDecoration(),
        child: const Center(
          child: Text('No products yet. Go to Products to add some.',
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final recent = _products.take(8).toList();
    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor:
              WidgetStateProperty.all(const Color(0xFFF8FAFB)),
          headingTextStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF374151)),
          dataTextStyle:
              const TextStyle(fontSize: 13, color: Color(0xFF111827)),
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Price')),
            DataColumn(label: Text('Stock')),
            DataColumn(label: Text('Status')),
          ],
          rows: recent.map((p) {
            final isOut = p.stock == 0;
            final isLow = p.stock > 0 && p.stock <= 10;
            return DataRow(cells: [
              DataCell(Text(p.name,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
              DataCell(_categoryChip(p.category)),
              DataCell(Text('₱${p.price.toStringAsFixed(2)}')),
              DataCell(Text('${p.stock}')),
              DataCell(_statusChip(isOut, isLow)),
            ]);
          }).toList(),
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
    final label = isOut
        ? 'Out of Stock'
        : isLow
            ? 'Low Stock'
            : 'In Stock';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2)),
      ],
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(2);
  }
}

// ── Stat Card Widget ─────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color)),
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
