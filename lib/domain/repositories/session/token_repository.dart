/// Contract for storing and retrieving the authentication access token.
abstract class TokenRepository {
  /// Returns the stored access token, or `null` if none exists.
  Future<String?> getToken();

  /// Persists the given [token].
  Future<void> saveToken(String token);

  /// Removes the stored access token.
  Future<void> deleteToken();
}
