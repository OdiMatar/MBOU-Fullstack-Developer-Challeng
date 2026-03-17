import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/cart_item.dart';

class CartService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  Map<String, dynamic> _decodeBody(String body) {
    if (body.isEmpty) {
      return {};
    }
    return json.decode(body) as Map<String, dynamic>;
  }

  Exception _apiException(http.Response response, String fallback) {
    final data = _decodeBody(response.body);
    return Exception(data['message'] ?? fallback);
  }

  Future<List<CartItem>> getUserCart(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/cart/user/$userId'));

    if (response.statusCode != 200) {
      throw _apiException(response, 'Kon winkelwagen niet ophalen');
    }

    final data = _decodeBody(response.body);
    final items = (data['data'] as List<dynamic>? ?? []);
    return items
        .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> addToCart({
    required int userId,
    required int itemId,
    required int quantity,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cart'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'item_id': itemId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 201) {
      throw _apiException(response, 'Toevoegen aan winkelwagen mislukt');
    }
  }

  Future<void> updateQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/cart/$cartItemId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'quantity': quantity}),
    );

    if (response.statusCode != 200) {
      throw _apiException(response, 'Aantal bijwerken mislukt');
    }
  }

  Future<void> removeFromCart(int cartItemId) async {
    final response = await http.delete(Uri.parse('$baseUrl/cart/$cartItemId'));

    if (response.statusCode != 200) {
      throw _apiException(response, 'Verwijderen uit winkelwagen mislukt');
    }
  }

  Future<double> checkout(int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cart/checkout'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'user_id': userId}),
    );

    if (response.statusCode != 200) {
      throw _apiException(response, 'Afrekenen mislukt');
    }

    final data = _decodeBody(response.body);
    return double.tryParse(data['total']?.toString() ?? '0') ?? 0;
  }
}
