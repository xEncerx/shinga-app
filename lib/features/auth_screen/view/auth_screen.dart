import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/core.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/widgets.dart';

@RoutePage()
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                ),
              );
            }
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('You auth as "${state.username}"'),
                ),
              );
              context.router.replaceAll([const FavoriteRoute()]);
            }
            if (state is SignUpSuccess || state is PasswordRecoverySuccess) {
              final recoveryCode = state is SignUpSuccess
                  ? state.recoveryCode
                  : (state as PasswordRecoverySuccess).recoveryCode;

              showDialog<void>(
                barrierDismissible: false,
                context: context,
                builder: (_) => RecoveryCodeDialog(
                  recoveryCode: recoveryCode,
                ),
              );
            }
          },
          child: const AutoRouter(),
        ),
      ),
    );
  }
}
