import 'package:shinga/data/data.dart';
import 'package:shinga/domain/domain.dart';
import 'package:storage/storage.dart';

/// Implementation of [SessionRepository] backed by local storage.
class SessionRepositoryImpl implements SessionRepository {
  /// Creates a [SessionRepositoryImpl] instance.
  const SessionRepositoryImpl(this._storage);

  final CollectionStorage<SessionDTO> _storage;

  static const String _kCurrentSessionId = 'current';

  @override
  Future<Session?> getSession() async {
    final dto = await _storage.read(_kCurrentSessionId);
    return dto?.toDomain();
  }

  @override
  Future<void> saveSession(Session session) {
    final dto = SessionDTO.fromDomain(session);
    return _storage.write(_kCurrentSessionId, dto);
  }

  @override
  Future<void> clearSession() => _storage.delete(_kCurrentSessionId);

  @override
  Stream<Session?> watchSession() {
    return _storage.watch().asyncMap((_) async {
      final dto = await _storage.read(_kCurrentSessionId);
      return dto?.toDomain();
    });
  }
}
