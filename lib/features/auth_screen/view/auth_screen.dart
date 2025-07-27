import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../utils/utils.dart';
import '../bloc/auth_bloc.dart';

/// Screen for user authentication (login/signup).
@RoutePage()
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(
        restClient: getIt<RestClient>(),
        secureStorageRepo: getIt<SecureStorageRepository>(),
      ),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            showSnackBar(context, state.message);
            // If user is signed in successfully, navigate to the main route
            if (state is AuthSignInSuccess){
              context.router.replaceAll([const MainRoute()]);
            }
          } else if (state is AuthFailure) {
            showSnackBar(context, state.error.detail);
          }
        },
        child: const AutoRouter(),
      ),
    );
  }
}
