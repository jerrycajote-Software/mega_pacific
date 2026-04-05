class StockLog {
  final int id;
  final int productId;
  final String productName;
  final String category;
  final String action; // 'add' or 'deduct'
  final int quantity;
  final String? note;
  final DateTime createdAt;

  const StockLog({
    required this.id,
    required this.productId,
    required this.productName,
    required this.category,
    required this.action,
    required this.quantity,
    this.note,
    required this.createdAt,
  });

  factory StockLog.fromJson(Map<String, dynamic> json) {
    return StockLog(
      id:          json['id'] as int,
      productId:   json['product_id'] as int,
      productName: json['product_name'] as String,
      category:    json['category'] as String,
      action:      json['action'] as String,
      quantity:    json['quantity'] as int,
      note:        json['note'] as String?,
      createdAt:   DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }
}
