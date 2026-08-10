import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/auth/domain/domain.dart';
import 'package:talker/talker.dart';

part 'session_event.dart';
part 'session_state.dart';

/// Manages the global user session state for the entire application.
///
/// Listens to [SessionRepository.watchSession] and reacts to session changes.
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  /// Creates a [SessionBloc] instance.
  SessionBloc({
    required this._authRepository,
    required this._sessionRepository,
    required this._logger,
  }) : super(SessionLoading()) {
    on<SessionLogoutRequested>(_onSessionLogoutRequested);
    on<_SessionChanged>(_onSessionChanged);

    _sessionSub = _sessionRepository.watchSession().listen(
      (session) => add(_SessionChanged(session: session)),
      onError: (Object error, StackTrace stackTrace) =>
          _logger.error('Session stream failed', error, stackTrace),
    );
  }

  final AuthRepository _authRepository;
  final SessionRepository _sessionRepository;
  StreamSubscription<Session?>? _sessionSub;
  final Talker _logger;
  bool _hasObservedInitialSession = false;

  Future<void> _onSessionLogoutRequested(
    SessionLogoutRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());
    await _authRepository.logout();
  }

  void _onSessionChanged(
    _SessionChanged event,
    Emitter<SessionState> emit,
  ) {
    final session = event.session;
    if (!_hasObservedInitialSession) {
      _hasObservedInitialSession = true;
      if (session != null) {
        unawaited(
          _authRepository.refreshSession().then(
            (result) => result.fold(
              (failure) => _logger.warning('Session refresh failed: $failure'),
              (_) => null,
            ),
          ),
        );
      }
    }

    if (session != null) {
      emit(SessionAuthenticated(session));
    } else {
      emit(SessionUnauthenticated());
    }
  }

  @override
  Future<void> close() async {
    await _sessionSub?.cancel();
    return super.close();
  }
}
