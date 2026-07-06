import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// A page that manages the password reset flow, allowing users to request a password reset and set a new password.
@RoutePage()
class PasswordResetPage extends StatelessWidget {
  /// Creates a [PasswordResetPage] widget.
  const PasswordResetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return BlocListener<PasswordResetBloc, PasswordResetState>(
      listener: (context, state) {
        if (state is PasswordResetFailure) {
          final message = state.failure.toMessage();
          ScaffoldMessengerHelper.showError(
            context: context,
            title: message.title,
            subtitle: message.description,
          );
        }
        if (state is PasswordResetSuccess) {
          ScaffoldMessengerHelper.showMessage(
            context: context,
            title: t.common.success,
            subtitle: t.auth.passwordReset.newPasswordStep.successMessage,
          );
          _closePage(context);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  children: [
                    BlocBuilder<PasswordResetBloc, PasswordResetState>(
                      buildWhen: (previous, current) =>
                          current is PasswordResetCodeVerified ||
                          current is PasswordResetEmailSent ||
                          current is PasswordResetInitial,
                      builder: (context, state) {
                        if (state is PasswordResetEmailSent) {
                          return const PasswordResetCodeStepView();
                        }
                        if (state is PasswordResetCodeVerified) {
                          return const PasswordResetNewPasswordStepView();
                        }
                        return const PasswordResetEmailStepView();
                      },
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SaText(t.auth.passwordReset.backToLogin),
                        SaTextButton(
                          onPressed: () => _closePage(context),
                          child: SaText(t.auth.login.loginButton),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _closePage(BuildContext context) => context.router.pop();
}
