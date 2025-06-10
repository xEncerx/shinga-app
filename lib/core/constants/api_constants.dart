import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class ApiConstants {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? "";

  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration connectTimeout = Duration(seconds: 10);
  static const int defaultLimit = 20;

  static const String yandexUrl = "https://ya.ru";
  static const String googleUrl = "https://www.google.com";
}
