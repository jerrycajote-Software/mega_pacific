import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/stock_log.dart';
import '../models/user.dart';
import '../models/review.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';
  static const String _tokenKey = 'jwt_token';

  // ─────────────────────────────────────────
  // Authentication Helpers
  // ─────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove('user_role');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    if (token != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  // ─────────────────────────────────────────
  // Authentication API
  // ─────────────────────────────────────────
  static Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      await saveToken(json['token']);
      final user = User.fromJson(json['user']);
      await saveRole(user.role);
      return user;
    }
    final error = jsonDecode(response.body)['error'] ?? 'Login failed';
    throw Exception(error);
  }

  static Future<User> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    
    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      await saveToken(json['token']);
      final user = User.fromJson(json['user']);
      await saveRole(user.role);
      return user;
    }
    final error = jsonDecode(response.body)['error'] ?? 'Registration failed';
    throw Exception(error);
  }

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
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: headers,
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
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: headers,
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
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body)['error'] ?? 'Unknown error';
      throw Exception(error);
    }
  }

  // ─────────────────────────────────────────
  // PATCH adjust stock (add or deduct)
  // ─────────────────────────────────────────
  static Future<Product> adjustStock(
    int productId,
    String action, // 'add' or 'deduct'
    int quantity,
    String? note,
  ) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('$baseUrl/products/$productId/stock'),
      headers: headers,
      body: jsonEncode({
        'action': action,
        'quantity': quantity,
        'note': note,
      }),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    }
    final error = jsonDecode(response.body)['error'] ?? 'Unknown error';
    throw Exception(error);
  }

  // ─────────────────────────────────────────
  // GET stock movement logs
  // ─────────────────────────────────────────
  static Future<List<StockLog>> getStockLogs({int? productId}) async {
    final uri = productId != null
        ? Uri.parse('$baseUrl/stock-logs?product_id=$productId')
        : Uri.parse('$baseUrl/stock-logs');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => StockLog.fromJson(json)).toList();
    }
    throw Exception('Failed to load stock logs: ${response.body}');
  }

  // ─────────────────────────────────────────
  // Reviews API
  // ─────────────────────────────────────────
  static Future<List<Review>> getReviews(int productId) async {
    final response = await http.get(Uri.parse('$baseUrl/reviews/product/$productId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Review.fromJson(json)).toList();
    }
    throw Exception('Failed to load reviews');
  }

  static Future<Review> addReview(int userId, int productId, int rating, String? comment) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/reviews'),
      headers: headers,
      body: jsonEncode({
        'user_id': userId,
        'product_id': productId,
        'rating': rating,
        'comment': comment,
      }),
    );
    
    if (response.statusCode == 201) {
      return Review.fromJson(jsonDecode(response.body));
    }
    final error = jsonDecode(response.body)['error'] ?? 'Failed to add review';
    throw Exception(error);
  }
}
