import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// A page that allows users to enter the verification code they received for password reset.
///
/// This is the second step of the password reset flow, where users input the code sent to their email to verify their identity before setting a new password.
class PasswordResetNewPasswordStepView extends StatefulWidget {
  /// Creates a [PasswordResetNewPasswordStepView] widget.
  const PasswordResetNewPasswordStepView({super.key});

  @override
  State<PasswordResetNewPasswordStepView> createState() => _PasswordResetNewPasswordStepViewState();
}

class _PasswordResetNewPasswordStepViewState extends State<PasswordResetNewPasswordStepView> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'password_reset_new_password_step_form');
  final _password2FocusNode = FocusNode();
  String _password1 = '';
  String _password2 = '';

  @override
  void dispose() {
    _password2FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          SaText(
            t.auth.passwordReset.newPasswordStep.title,
            style: AppTextStyle.h4,
          ),
          const SizedBox(height: AppSpacing.s),
          SaText(
            t.auth.passwordReset.newPasswordStep.subtitle,
            style: AppTextStyle.titleS,
          ),
          const SizedBox(height: AppSpacing.xl),
          SaFormTextField(
            textInputAction: TextInputAction.next,
            prefixIcon: const SaIcon(
              icon: SaIconSource.huge(HugeIconsStrokeRounded.lockPassword),
            ),
            labelText: t.auth.passwordReset.newPasswordStep.newPasswordLabel,
            isPassword: true,
            validator: FormValidator.password(),
            onSaved: (value) => _password1 = value ?? '',
            errorMaxLines: 2,
            onSubmitted: (_) => _password2FocusNode.requestFocus(),
          ),
          const SizedBox(height: AppSpacing.l),
          SaFormTextField(
            focusNode: _password2FocusNode,
            textInputAction: TextInputAction.done,
            prefixIcon: const SaIcon(
              icon: SaIconSource.huge(HugeIconsStrokeRounded.lockPassword),
            ),
            labelText: t.auth.passwordReset.newPasswordStep.confirmPasswordLabel,
            isPassword: true,
            validator: FormValidator.password(),
            onSaved: (value) => _password2 = value ?? '',
            errorMaxLines: 2,
            onSubmitted: (_) => _onVerifyCodePressed(),
          ),
          const SizedBox(height: AppSpacing.xl),
          BlocBuilder<PasswordResetBloc, PasswordResetState>(
            builder: (_, state) {
              final isLoading = state is PasswordResetLoading;

              return SaPrimaryButton.icon(
                onPressed: _onVerifyCodePressed,
                isLoading: isLoading,
                iconAlignment: SaIconAlignment.end,
                label: SaText(t.auth.passwordReset.newPasswordStep.resetButton),
                icon: const SaIcon(
                  icon: SaIconSource.huge(HugeIconsStrokeRounded.arrowRight01),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _onVerifyCodePressed() {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    formState.save();
    if (_password1 != _password2) {
      final t = Translations.of(context);

      ScaffoldMessengerHelper.showError(
        context: context,
        title: t.auth.passwordReset.title,
        subtitle: t.auth.passwordReset.newPasswordStep.passwordsDoNotMatchError,
      );
      return;
    }
    context.read<PasswordResetBloc>().add(
      PasswordResetNewPasswordSubmitted(newPassword: _password2),
    );
  }
}
