import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/auth/auth.dart';

part 'login_state.dart';

/// Handles user login form submission.
class LoginCubit extends Cubit<LoginState> {
  /// Creates a [LoginCubit] instance.
  LoginCubit({required this._authRepository}) : super(LoginInitial());

  final AuthRepository _authRepository;

  /// Submits [identifier] and [password] to the authentication repository.
  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    emit(LoginLoading());
    final result = await _authRepository.login(
      identifier: identifier,
      password: password,
    );
    result.fold(
      (failure) => emit(LoginFailure(failure)),
      (_) => emit(LoginSuccess()),
    );
  }

  /// Resets the cubit to its initial state.
  void reset() => emit(LoginInitial());
}
