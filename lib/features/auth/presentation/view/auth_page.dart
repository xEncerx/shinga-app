import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/features/auth/auth.dart';

/// The main authentication page that manages the login, sign-up, and password reset flows.
///
/// This page uses a [MultiBlocProvider] to provide the necessary cubits and blocs for the authentication features,
/// and an [AutoRouter] to handle navigation between the different authentication steps.
@RoutePage()
class AuthPage extends StatelessWidget {
  /// Creates an [AuthPage] widget.
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = context.deps.authRepository;
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginCubit>(
          create: (_) => LoginCubit(authRepository: authRepo),
        ),
        BlocProvider<SignUpCubit>(
          create: (_) => SignUpCubit(authRepository: authRepo),
        ),
        BlocProvider<PasswordResetBloc>(
          create: (_) => PasswordResetBloc(authRepo),
        ),
      ],
      child: const AutoRouter(),
    );
  }
}
