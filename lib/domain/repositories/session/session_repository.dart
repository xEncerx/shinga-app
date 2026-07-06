import 'package:shinga/domain/entities/entities.dart';

/// Contract for persisting and observing the current user session.
abstract class SessionRepository {
  /// Returns the stored [Session], or `null` if no session exists.
  Future<Session?> getSession();

  /// Persists the given [session].
  Future<void> saveSession(Session session);

  /// Removes the current session from storage.
  Future<void> clearSession();

  /// Emits the current [Session] and any subsequent changes.
  /// Emits `null` when there is no active session.
  Stream<Session?> watchSession();
}
