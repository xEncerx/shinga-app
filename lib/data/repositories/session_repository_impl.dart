import 'package:drift/drift.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/data/data.dart';
import 'package:shinga/domain/domain.dart';

/// Implements [SessionRepository] with a reactive Drift DAO.
class SessionRepositoryImpl implements SessionRepository {
  /// Creates a [SessionRepositoryImpl] instance.
  const SessionRepositoryImpl(this._dao);

  final SessionDao _dao;

  @override
  Future<Session?> getSession() => StorageExceptionGuard.read(
    () async => (await _dao.getCurrentSession())?.toDomain(),
  );

  @override
  Future<void> saveSession(Session session) {
    final user = session.user;
    return StorageExceptionGuard.write(
      () => _dao.saveCurrentSession(
        CurrentSessionTableCompanion.insert(
          id: const Value(1),
          userId: user.id,
          username: user.username,
          email: user.email,
          avatarPath: user.avatarUrl,
          role: user.role.name,
          description: Value(user.description),
        ),
      ),
    );
  }

  @override
  Future<void> clearSession() => StorageExceptionGuard.delete(_dao.clearCurrentSession);

  @override
  Stream<Session?> watchSession() => _dao.watchCurrentSession().map((row) => row?.toDomain());
}

extension on CurrentSessionRow {
  Session toDomain() => Session(
    user: UserEntity(
      id: userId,
      username: username,
      email: email,
      avatarUrl: avatarPath,
      role: UserRole.values.byNameOrDefault(role, UserRole.user),
      description: description,
    ),
  );
}
