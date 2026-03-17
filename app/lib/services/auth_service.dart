import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class AuthService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  // Simpele in-memory opslag (voor demo)
  static Map<String, dynamic>? _currentUser;

  Future<void> setCurrentUser(Map<String, dynamic> user) async {
    _currentUser = user;
  }

  Future<void> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _currentUser = data['user'];
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Registratie mislukt');
      }
    } catch (e) {
      throw Exception('Fout bij registreren: $e');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentUser = data['user'];
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Inloggen mislukt');
      }
    } catch (e) {
      throw Exception('Fout bij inloggen: $e');
    }
  }

  Future<void> logout() async {
    _currentUser = null;
  }

  Future<Map<String, dynamic>?> getUser() async {
    return _currentUser;
  }

  Future<bool> isLoggedIn() async {
    return _currentUser != null;
  }

  Future<bool> isAdmin() async {
    return _currentUser?['role'] == 'admin';
  }
}
