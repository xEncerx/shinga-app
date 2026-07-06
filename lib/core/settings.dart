/// A class that holds the application settings.
class Settings {
  /// The base URL for the application.
  static const String baseUrl = String.fromEnvironment('BASE_URL');

  /// The base URL for the API.
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');
}
