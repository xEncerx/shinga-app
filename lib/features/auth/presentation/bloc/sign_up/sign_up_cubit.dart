import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/auth/auth.dart';

part 'sign_up_state.dart';

/// Handles user registration form submission.
class SignUpCubit extends Cubit<SignUpState> {
  /// Creates a [SignUpCubit] instance.
  SignUpCubit({required this._authRepository}) : super(SignUpInitial());

  final AuthRepository _authRepository;

  /// Submits registration data to the authentication repository.
  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    emit(SignUpLoading());
    final result = await _authRepository.signUp(
      username: username,
      email: email,
      password: password,
    );
    result.fold(
      (failure) => emit(SignUpFailure(failure)),
      (_) => emit(SignUpSuccess()),
    );
  }

  /// Resets the cubit to its initial state.
  void reset() => emit(SignUpInitial());
}
