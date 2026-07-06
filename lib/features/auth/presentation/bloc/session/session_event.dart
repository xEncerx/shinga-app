part of 'session_bloc.dart';

/// Base event for session management in the authentication flow.
sealed class SessionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Dispatched on application startup to check for an existing session.
final class SessionStarted extends SessionEvent {}

/// Dispatched when the user requests to log out.
final class SessionLogoutRequested extends SessionEvent {}

/// Internal event dispatched when the session changes to update the authentication state accordingly.
final class _SessionChanged extends SessionEvent {
  _SessionChanged({required this.session});

  final Session? session;

  @override
  List<Object?> get props => [session];
}
