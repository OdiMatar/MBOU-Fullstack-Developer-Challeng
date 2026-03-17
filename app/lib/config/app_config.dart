import 'package:flutter/foundation.dart';

class AppConfig {
  // Override voor fysieke telefoon: --dart-define=API_HOST=192.168.x.x
  static const String _apiHost = String.fromEnvironment(
    'API_HOST',
    defaultValue: kIsWeb ? 'localhost' : '10.0.2.2',
  );

  static String get serverBaseUrl => 'http://$_apiHost:8000';
  static String get apiBaseUrl => '$serverBaseUrl/api';
}
