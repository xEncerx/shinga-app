import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shinga/data/data.dart';
import 'package:shinga/domain/domain.dart';

/// Implementation of [TokenRepository] backed by secure storage.
class TokenRepositoryImpl implements TokenRepository {
  /// Creates a [TokenRepositoryImpl] instance.
  TokenRepositoryImpl(this._storage);

  final FlutterSecureStorage _storage;

  /// The key used to store the token in [_storage].
  static const _tokenKey = 'authToken';

  @override
  Future<String?> getToken() => StorageExceptionGuard.read(
    () => _storage.read(key: _tokenKey),
  );

  @override
  Future<void> saveToken(String token) => StorageExceptionGuard.write(
    () => _storage.write(key: _tokenKey, value: token),
  );

  @override
  Future<void> deleteToken() => StorageExceptionGuard.delete(
    () => _storage.delete(key: _tokenKey),
  );
}
