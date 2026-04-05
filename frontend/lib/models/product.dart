class Product {
  final int? id;
  final String name;
  final String category;
  final double price;
  final int stock;

  const Product({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id:       json['id'] as int?,
      name:     json['name'] as String,
      category: json['category'] as String,
      price:    double.parse(json['price'].toString()),
      stock:    json['stock'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name':     name,
      'category': category,
      'price':    price,
      'stock':    stock,
    };
  }

  Product copyWith({
    int?    id,
    String? name,
    String? category,
    double? price,
    int?    stock,
  }) {
    return Product(
      id:       id       ?? this.id,
      name:     name     ?? this.name,
      category: category ?? this.category,
      price:    price    ?? this.price,
      stock:    stock    ?? this.stock,
    );
  }
}
