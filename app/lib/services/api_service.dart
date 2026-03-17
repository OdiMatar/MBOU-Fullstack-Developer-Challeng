import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item.dart';
import '../config/app_config.dart';

class ApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  Future<List<Item>> getItems() async {
    print('🔵 API Call: Getting items from $baseUrl/items');
    try {
      final response = await http.get(Uri.parse('$baseUrl/items'));
      print('🔵 Response status: ${response.statusCode}');
      print('🔵 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List itemsJson = data['data'];
        print('🟢 Success: Loaded ${itemsJson.length} items');
        return itemsJson.map((json) => Item.fromJson(json)).toList();
      } else {
        print('🔴 Error: Status code ${response.statusCode}');
        throw Exception('Kon items niet ophalen');
      }
    } catch (e) {
      print('🔴 Exception: $e');
      throw Exception('Fout bij ophalen items: $e');
    }
  }

  Future<Item> createItem(
    String name,
    String description, {
    String? brand,
    double? price,
    int? stock,
    String? imageUrl,
  }) async {
    print('🔵 API Call: Creating item - name: $name');
    try {
      final body = {
        'name': name,
        'description': description,
        'brand': ?brand,
        'price': ?price,
        'stock': ?stock,
        'image_url': ?imageUrl,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/items'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      print('🔵 Response status: ${response.statusCode}');
      print('🔵 Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('🟢 Success: Item created');
        return Item.fromJson(data['data']);
      } else {
        print('🔴 Error: Status code ${response.statusCode}');
        throw Exception('Kon item niet aanmaken');
      }
    } catch (e) {
      print('🔴 Exception: $e');
      throw Exception('Fout bij aanmaken item: $e');
    }
  }

  Future<Item> updateItem(
    int id,
    String name,
    String description, {
    String? brand,
    double? price,
    int? stock,
    String? imageUrl,
  }) async {
    print('🔵 API Call: Updating item $id');
    try {
      final body = {
        'name': name,
        'description': description,
        'brand': ?brand,
        'price': ?price,
        'stock': ?stock,
        'image_url': ?imageUrl,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/items/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      print('🔵 Response status: ${response.statusCode}');
      print('🔵 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🟢 Success: Item updated');
        return Item.fromJson(data['data']);
      } else {
        print('🔴 Error: Status code ${response.statusCode}');
        throw Exception('Kon item niet updaten');
      }
    } catch (e) {
      print('🔴 Exception: $e');
      throw Exception('Fout bij updaten item: $e');
    }
  }

  Future<void> deleteItem(int id) async {
    print('🔵 API Call: Deleting item $id');
    try {
      final response = await http.delete(Uri.parse('$baseUrl/items/$id'));
      print('🔵 Response status: ${response.statusCode}');
      print('🔵 Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('🟢 Success: Item deleted');
      } else {
        print('🔴 Error: Status code ${response.statusCode}');
        throw Exception('Kon item niet verwijderen');
      }
    } catch (e) {
      print('🔴 Exception: $e');
      throw Exception('Fout bij verwijderen item: $e');
    }
  }
}
