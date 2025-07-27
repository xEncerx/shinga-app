import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/models.dart';

class SecureStorageRepository {
  static const String _tokenKey = 'jwt_token';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// Saves the token to secure storage
  Future<void> saveToken(Token token) async {
    await _storage.write(
      key: _tokenKey,
      value: token.accessToken,
    );
  }

  /// Retrieves the token from secure storage
  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  /// Deletes the token from secure storage
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
