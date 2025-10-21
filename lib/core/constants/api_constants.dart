/// API configuration constants used for network requests.
abstract class ApiConstants {
  /// Base URL for the API, loaded from environment variables.
  static const String baseUrl = String.fromEnvironment('API_BASE_URL');
  static const String apiUrl = '$baseUrl/api/v1/';

  /// Maximum time to wait for a server response.
  static const Duration receiveTimeout = Duration(seconds: 10);

  /// Maximum time to establish a connection.
  static const Duration connectTimeout = Duration(seconds: 10);

  /// URL for the Google homepage.
  static const String googleUrl = 'https://www.google.com';

  /// URL for the Github repository.
  static const String githubRepoUrl = 'https://github.com/xEncerx/shinga-app';
}
