import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  // ─────────────────────────────────────────
  // GET all products
  // ─────────────────────────────────────────
  static Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Failed to load products: ${response.body}');
  }

  // ─────────────────────────────────────────
  // POST create a new product
  // ─────────────────────────────────────────
  static Future<Product> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body));
    }
    final error = jsonDecode(response.body)['error'] ?? 'Unknown error';
    throw Exception(error);
  }

  // ─────────────────────────────────────────
  // PUT update an existing product
  // ─────────────────────────────────────────
  static Future<Product> updateProduct(int id, Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    }
    final error = jsonDecode(response.body)['error'] ?? 'Unknown error';
    throw Exception(error);
  }

  // ─────────────────────────────────────────
  // DELETE a product
  // ─────────────────────────────────────────
  static Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body)['error'] ?? 'Unknown error';
      throw Exception(error);
    }
  }
}
