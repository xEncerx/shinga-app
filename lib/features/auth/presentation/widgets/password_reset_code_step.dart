import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// A page that allows users to enter the verification code they received for password reset.
///
/// This is the second step of the password reset flow, where users input the code sent to their email to verify their identity before setting a new password.
class PasswordResetCodeStepView extends StatefulWidget {
  /// Creates a [PasswordResetCodeStepView] widget.
  const PasswordResetCodeStepView({super.key});

  @override
  State<PasswordResetCodeStepView> createState() => _PasswordResetCodeStepViewState();
}

class _PasswordResetCodeStepViewState extends State<PasswordResetCodeStepView> {
  final _formKey = GlobalKey<FormBuilderState>(debugLabel: 'password_reset_code_step_form');

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Column(
      children: [
        SaText(
          t.auth.passwordReset.verificationStep.title,
          style: AppTextStyle.h4,
        ),
        const SizedBox(height: AppSpacing.s),
        SaText(
          t.auth.passwordReset.verificationStep.subtitle,
          style: AppTextStyle.titleS,
        ),
        const SizedBox(height: AppSpacing.xl),
        FormBuilder(
          key: _formKey,
          child: SaFormPinField(
            formKeyName: 'code',
            validator: FormValidator.verificationCode(),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (_) => _onVerifyCodePressed,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        BlocBuilder<PasswordResetBloc, PasswordResetState>(
          builder: (_, state) {
            final isLoading = state is PasswordResetLoading;

            return SaPrimaryButton.icon(
              onPressed: _onVerifyCodePressed,
              isLoading: isLoading,
              iconAlignment: SaIconAlignment.end,
              label: SaText(t.auth.passwordReset.verificationStep.verifyButton),
              icon: const SaIcon(
                icon: SaIconSource.huge(HugeIconsStrokeRounded.checkmarkBadge01),
              ),
            );
          },
        ),
      ],
    );
  }

  void _onVerifyCodePressed() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final code = _formKey.currentState?.value['code'] as String;
      context.read<PasswordResetBloc>().add(PasswordResetCodeSubmitted(code: code));
    }
  }
}
