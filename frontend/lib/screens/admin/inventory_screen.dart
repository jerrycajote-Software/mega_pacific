import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/product.dart';
import '../../models/stock_log.dart';
import '../../services/api_service.dart';

// ── Category color mapping ────────────────────────────────
const Map<String, Color> _catColors = {
  'Roofing':     Color(0xFF1565C0),
  'Structural':  Color(0xFF6D4C41),
  'Ceiling':     Color(0xFF2E7D32),
  'Decking':     Color(0xFF5E35B1),
  'Accessories': Color(0xFFF57C00),
};

Color _catColor(String cat) => _catColors[cat] ?? const Color(0xFF607D8B);

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Product>  _products = [];
  List<StockLog> _logs     = [];
  bool   _loading     = true;
  bool   _logsLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadProducts(), _loadLogs()]);
  }

  Future<void> _loadProducts() async {
    setState(() { _loading = true; _error = null; });
    try {
      final p = await ApiService.getProducts();
      setState(() { _products = p; _loading = false; });
    } catch (e) {
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _loadLogs() async {
    setState(() => _logsLoading = true);
    try {
      final l = await ApiService.getStockLogs();
      setState(() { _logs = l; _logsLoading = false; });
    } catch (_) {
      setState(() => _logsLoading = false);
    }
  }

  // ── Category summary ─────────────────────────────────
  Map<String, int> get _categoryTotals {
    final Map<String, int> totals = {};
    for (final p in _products) {
      totals[p.category] = (totals[p.category] ?? 0) + p.stock;
    }
    return totals;
  }

  // ── Stock adjustment dialog ───────────────────────────
  Future<void> _showAdjustDialog(Product product, String action) async {
    final qtyCtrl  = TextEditingController();
    final noteCtrl = TextEditingController();
    final formKey  = GlobalKey<FormState>();
    bool submitting = false;
    String? dialogError;

    final color  = action == 'add' ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final icon   = action == 'add' ? Icons.add_circle_outline : Icons.remove_circle_outline;
    final label  = action == 'add' ? 'Add Stock' : 'Deduct Stock';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: color)),
                      Text(product.name,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
                Text('Current: ${product.stock}',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color)),
              ],
            ),
          ),
          content: SizedBox(
            width: 380,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  // Quantity field
                  TextFormField(
                    controller: qtyCtrl,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Quantity *',
                      hintText: 'e.g. 50',
                      prefixIcon: Icon(icon, color: color, size: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: color, width: 2),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Quantity is required';
                      final n = int.tryParse(v);
                      if (n == null || n <= 0) return 'Enter a positive number';
                      if (action == 'deduct' && n > product.stock) {
                        return 'Cannot deduct more than ${product.stock} in stock';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  // Note field
                  TextFormField(
                    controller: noteCtrl,
                    maxLength: 200,
                    decoration: InputDecoration(
                      labelText: 'Reason / Note (optional)',
                      hintText: action == 'add'
                          ? 'e.g. New delivery from supplier'
                          : 'e.g. Customer order #123',
                      prefixIcon: const Icon(Icons.note_outlined,
                          color: Colors.grey, size: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      counterText: '',
                    ),
                  ),
                  if (dialogError != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(dialogError!,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              icon: submitting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Icon(icon, size: 16),
              label: Text(submitting ? 'Saving…' : label),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: submitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() {
                        submitting = true;
                        dialogError = null;
                      });
                      try {
                        final qty  = int.parse(qtyCtrl.text.trim());
                        final note = noteCtrl.text.trim().isEmpty
                            ? null
                            : noteCtrl.text.trim();
                        await ApiService.adjustStock(
                            product.id!, action, qty, note);
                        if (ctx.mounted) Navigator.pop(ctx, true);
                      } catch (e) {
                        setDialogState(() {
                          submitting = false;
                          dialogError = e.toString().replaceFirst('Exception: ', '');
                        });
                      }
                    },
            ),
          ],
        ),
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        _loadAll();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${action == 'add' ? '✅ Added' : '🔴 Deducted'} ${qtyCtrl.text} sheet(s) of ${product.name}'),
            backgroundColor:
                action == 'add' ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F4F8),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildError()
                    : _buildBody(),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Inventory Management',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1B2A))),
              SizedBox(height: 2),
              Text('Manage stock levels — add or deduct per product',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _loadAll,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Refresh'),
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1565C0)),
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
          const Icon(Icons.cloud_off_rounded,
              size: 56, color: Colors.redAccent),
          const SizedBox(height: 12),
          const Text('Could not connect to server',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(_error ?? '',
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadAll,
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
          // ── Category Summary Cards ─────────────────
          _buildSectionTitle('Stock by Category'),
          const SizedBox(height: 12),
          _buildCategoryCards(),
          const SizedBox(height: 28),

          // ── Product Stock Table ────────────────────
          Row(
            children: [
              _buildSectionTitle('Product Inventory'),
              const Spacer(),
              _buildLegend(),
            ],
          ),
          const SizedBox(height: 12),
          _buildProductTable(),
          const SizedBox(height: 28),

          // ── Recent Activity ────────────────────────
          _buildSectionTitle('Recent Stock Activity'),
          const SizedBox(height: 12),
          _buildActivityLog(),
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

  Widget _buildLegend() {
    return Row(
      children: [
        _legendChip('In Stock', const Color(0xFF2E7D32), const Color(0xFFE8F5E9)),
        const SizedBox(width: 8),
        _legendChip('Low Stock', const Color(0xFFF57C00), const Color(0xFFFFF8E1)),
        const SizedBox(width: 8),
        _legendChip('Out of Stock', const Color(0xFFC62828), const Color(0xFFFFEBEE)),
      ],
    );
  }

  Widget _legendChip(String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }

  // ── Category Cards ────────────────────────────────────
  Widget _buildCategoryCards() {
    final totals = _categoryTotals;
    final categories = totals.keys.toList();
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: categories.map((cat) {
        final stock  = totals[cat] ?? 0;
        final color  = _catColor(cat);
        final count  = _products.where((p) => p.category == cat).length;
        return Container(
          width: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.inventory_2_rounded,
                    color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text('$stock',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color)),
              Text('units total',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500)),
              const SizedBox(height: 4),
              Text(cat,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF0D1B2A))),
              Text('$count product${count == 1 ? '' : 's'}',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Product Table ─────────────────────────────────────
  Widget _buildProductTable() {
    if (_products.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: _cardDecoration(),
        child: const Center(
            child: Text('No products found.',
                style: TextStyle(color: Colors.grey))),
      );
    }

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
          dataTextStyle: const TextStyle(
              fontSize: 13, color: Color(0xFF111827)),
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text('Product')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Price')),
            DataColumn(label: Text('Stock'), numeric: true),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: _products.map((p) {
            final isOut = p.stock == 0;
            final isLow = p.stock > 0 && p.stock <= 10;
            return DataRow(cells: [
              DataCell(Text(p.name,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
              DataCell(_categoryBadge(p.category)),
              DataCell(Text('₱${p.price.toStringAsFixed(2)}')),
              DataCell(Text(
                '${p.stock}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isOut
                        ? const Color(0xFFC62828)
                        : isLow
                            ? const Color(0xFFF57C00)
                            : const Color(0xFF111827)),
              )),
              DataCell(_statusChip(isOut, isLow)),
              DataCell(_actionButtons(p)),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _categoryBadge(String category) {
    final color = _catColor(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(category,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
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
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }

  Widget _actionButtons(Product product) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Add Stock
        Tooltip(
          message: 'Add Stock',
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _showAdjustDialog(product, 'add'),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add_rounded,
                  color: Color(0xFF2E7D32), size: 18),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Deduct Stock
        Tooltip(
          message: 'Deduct Stock',
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: product.stock == 0
                ? null
                : () => _showAdjustDialog(product, 'deduct'),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: product.stock == 0
                    ? Colors.grey.shade100
                    : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.remove_rounded,
                  color: product.stock == 0
                      ? Colors.grey.shade300
                      : const Color(0xFFC62828),
                  size: 18),
            ),
          ),
        ),
      ],
    );
  }

  // ── Activity Log ──────────────────────────────────────
  Widget _buildActivityLog() {
    if (_logsLoading) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator()));
    }
    if (_logs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: _cardDecoration(),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.history_rounded, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text('No stock movements yet.',
                  style: TextStyle(color: Colors.grey)),
              SizedBox(height: 4),
              Text('Use the + / − buttons above to adjust stock.',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: _logs.take(30).map((log) => _buildLogRow(log)).toList(),
      ),
    );
  }

  Widget _buildLogRow(StockLog log) {
    final isAdd   = log.action == 'add';
    final color   = isAdd ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final bgColor = isAdd ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final sign    = isAdd ? '+' : '−';
    final catColor = _catColor(log.category);

    final now  = DateTime.now();
    final diff = now.difference(log.createdAt);
    String timeStr;
    if (diff.inMinutes < 1) {
      timeStr = 'just now';
    } else if (diff.inMinutes < 60) {
      timeStr = '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      timeStr = '${diff.inHours}h ago';
    } else {
      final d = log.createdAt;
      timeStr = '${d.month}/${d.day}/${d.year}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Row(
        children: [
          // Action badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Text(sign,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ),
          ),
          const SizedBox(width: 14),
          // Product + note
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(log.productName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF111827))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(log.category,
                          style: TextStyle(
                              color: catColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                if (log.note != null && log.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(log.note!,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12)),
                  ),
              ],
            ),
          ),
          // Quantity + time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$sign${log.quantity} sheets',
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
              const SizedBox(height: 2),
              Text(timeStr,
                  style: TextStyle(
                      color: Colors.grey.shade400, fontSize: 11)),
            ],
          ),
        ],
      ),
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
            offset: const Offset(0, 2))
      ],
    );
  }
}
