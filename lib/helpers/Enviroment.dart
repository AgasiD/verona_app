import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static bool get isProduction => kReleaseMode ? true : false;
  static String get fileName =>
      kReleaseMode ? "enviroments/prod/.env" : "enviroments/dev/.env";
  static String get API_URL => dotenv.env['API_URL'] ?? '192.168.0.155:8008';
}
