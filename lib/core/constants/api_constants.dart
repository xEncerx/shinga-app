import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API configuration constants used for network requests.
abstract class ApiConstants {
  /// Base URL for the API, loaded from environment variables.
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? "";

  /// Maximum time to wait for a server response.
  static const Duration receiveTimeout = Duration(seconds: 10);

  /// Maximum time to establish a connection.
  static const Duration connectTimeout = Duration(seconds: 10);

  /// Default number of items per page in paginated responses.
  static const int defaultLimit = 20;

  /// URL for Yandex search engine.
  static const String yandexUrl = "https://ya.ru";

  /// URL for Google search engine.
  static const String googleUrl = "https://www.google.com";
}
