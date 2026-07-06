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
  final _formKey = GlobalKey<FormBuilderState>(debugLabel: 'password_reset_new_password_step_form');
  final _password2FocusNode = FocusNode();

  @override
  void dispose() {
    _password2FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return FormBuilder(
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
            formKeyName: 'password1',
            textInputAction: TextInputAction.next,
            prefixIcon: const SaIcon(
              icon: SaIconSource.huge(HugeIconsStrokeRounded.lockPassword),
            ),
            labelText: t.auth.passwordReset.newPasswordStep.newPasswordLabel,
            isPassword: true,
            validator: FormValidator.password(),
            errorMaxLines: 2,
            onSubmitted: (_) => _password2FocusNode.requestFocus(),
          ),
          const SizedBox(height: AppSpacing.l),
          SaFormTextField(
            formKeyName: 'password2',
            focusNode: _password2FocusNode,
            textInputAction: TextInputAction.done,
            prefixIcon: const SaIcon(
              icon: SaIconSource.huge(HugeIconsStrokeRounded.lockPassword),
            ),
            labelText: t.auth.passwordReset.newPasswordStep.confirmPasswordLabel,
            isPassword: true,
            validator: FormValidator.password(),
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
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final password1 = _formKey.currentState?.value['password1'] as String;
      final password2 = _formKey.currentState?.value['password2'] as String;

      if (password1 != password2) {
        final t = Translations.of(context);

        ScaffoldMessengerHelper.showError(
          context: context,
          title: t.auth.passwordReset.title,
          subtitle: t.auth.passwordReset.newPasswordStep.passwordsDoNotMatchError,
        );
        return;
      }
      context.read<PasswordResetBloc>().add(
        PasswordResetNewPasswordSubmitted(newPassword: password2),
      );
    }
  }
}
