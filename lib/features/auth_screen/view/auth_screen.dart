import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/core.dart';
import '../../../cubit/cubit.dart';
import '../../../i18n/strings.g.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/widgets.dart';

@RoutePage()
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Draft version of the auth menu translation
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final languageCode = t.$meta.locale.languageCode;
          await context.read<AppSettingsCubit>().setLanguageCode(
                languageCode == 'ru' ? 'en' : 'ru',
              );
        },
        child: const Icon(
          HugeIcons.strokeRoundedLanguageSkill,
        ),
      ),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) async {
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

              await showDialog<void>(
                barrierDismissible: false,
                context: context,
                builder: (_) => RecoveryCodeDialog(
                  recoveryCode: recoveryCode,
                ),
              );
              if (context.mounted) {
                context.router.replaceAll([const FavoriteRoute()]);
              }
            }
          },
          child: const AutoRouter(),
        ),
      ),
    );
  }
}
