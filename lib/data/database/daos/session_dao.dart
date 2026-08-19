part of '../app_database.dart';

/// Provides access to the current authenticated session snapshot.
@DriftAccessor(tables: [CurrentSessionTable])
final class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  /// Creates a DAO attached to its database.
  SessionDao(super.attachedDatabase);

  static const _sessionId = 1;

  /// Returns the current session row, or `null` when signed out.
  Future<CurrentSessionRow?> getCurrentSession() => _currentSessionQuery().getSingleOrNull();

  /// Emits the current row and every subsequent committed change.
  Stream<CurrentSessionRow?> watchCurrentSession() => _currentSessionQuery().watchSingleOrNull();

  /// Inserts or replaces the current session snapshot.
  Future<void> saveCurrentSession(CurrentSessionTableCompanion session) =>
      into(currentSessionTable).insertOnConflictUpdate(session);

  /// Removes the current session if present.
  Future<void> clearCurrentSession() =>
      (delete(currentSessionTable)..where((row) => row.id.equals(_sessionId))).go();

  SimpleSelectStatement<$CurrentSessionTableTable, CurrentSessionRow> _currentSessionQuery() {
    return select(currentSessionTable)..where((row) => row.id.equals(_sessionId));
  }
}
