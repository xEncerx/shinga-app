import 'package:shinga/domain/domain.dart';
import 'package:storage/storage.dart';

/// Implementation of [TokenRepository] backed by secure storage.
class TokenRepositoryImpl implements TokenRepository {
  /// Creates a [TokenRepositoryImpl] instance.
  TokenRepositoryImpl(this._storage);

  final KeyValueStorage _storage;

  /// The key used to store the token in [_storage].
  static const _tokenKey = 'authToken';

  @override
  Future<String?> getToken() => _storage.read(_tokenKey);

  @override
  Future<void> saveToken(String token) async => _storage.write(_tokenKey, token);

  @override
  Future<void> deleteToken() async => _storage.delete(_tokenKey);
}
