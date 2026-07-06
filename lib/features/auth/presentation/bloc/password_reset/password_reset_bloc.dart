import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/auth/auth.dart';

part 'password_reset_event.dart';
part 'password_reset_state.dart';

/// Bloc handling the password reset flow in the authentication feature.
class PasswordResetBloc extends Bloc<PasswordResetEvent, PasswordResetState> {
  /// Creates a [PasswordResetBloc] with the given [authRepository].
  PasswordResetBloc(AuthRepository authRepository)
    : _authRepository = authRepository,
      super(PasswordResetInitial()) {
    on<PasswordResetRequested>(_onRequestResetCode);
    on<PasswordResetCodeSubmitted>(_onSubmitResetCode);
    on<PasswordResetNewPasswordSubmitted>(_onSubmitNewPassword);
  }

  final AuthRepository _authRepository;
  String _email = '';
  String _code = '';

  Future<void> _onRequestResetCode(
    PasswordResetRequested event,
    Emitter<PasswordResetState> emit,
  ) async {
    emit(PasswordResetLoading());

    final result = await _authRepository.requestPasswordReset(
      email: event.email,
      emailLanguage: event.emailLanguage,
    );

    result.fold(
      (failure) => emit(PasswordResetFailure(failure: failure, step: PasswordResetStep.email)),
      (_) {
        _email = event.email;
        emit(PasswordResetEmailSent(email: event.email));
      },
    );
  }

  Future<void> _onSubmitResetCode(
    PasswordResetCodeSubmitted event,
    Emitter<PasswordResetState> emit,
  ) async {
    emit(PasswordResetLoading());

    final result = await _authRepository.verifyResetCode(
      email: _email,
      code: event.code,
    );

    result.fold(
      (failure) => emit(PasswordResetFailure(failure: failure, step: PasswordResetStep.code)),
      (_) {
        _code = event.code;
        emit(PasswordResetCodeVerified(email: _email, code: event.code));
      },
    );
  }

  Future<void> _onSubmitNewPassword(
    PasswordResetNewPasswordSubmitted event,
    Emitter<PasswordResetState> emit,
  ) async {
    emit(PasswordResetLoading());

    final result = await _authRepository.resetPassword(
      email: _email,
      code: _code,
      newPassword: event.newPassword,
    );

    result.fold(
      (failure) =>
          emit(PasswordResetFailure(failure: failure, step: PasswordResetStep.newPassword)),
      (_) {
        _email = '';
        _code = '';
        emit(PasswordResetSuccess());
      },
    );
  }
}
