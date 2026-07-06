part of 'session_bloc.dart';

/// Base state for session management in the authentication flow.
sealed class SessionState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state before session check.
final class SessionInitial extends SessionState {}

/// Session is being checked or logout is in progress.
final class SessionLoading extends SessionState {}

/// User is authenticated with an active [session].
final class SessionAuthenticated extends SessionState {
  /// Creates a [SessionAuthenticated] state.
  SessionAuthenticated(this.session);

  /// The current authenticated session.
  final Session session;

  @override
  List<Object?> get props => [session];
}

/// No active session exists.
final class SessionUnauthenticated extends SessionState {}
