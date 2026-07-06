import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// A page that allows users to reset their password by entering their email.
///
/// This is the first step of the password reset flow, where users provide their email to receive a reset code.
class PasswordResetEmailStepView extends StatefulWidget {
  /// Creates a [PasswordResetEmailStepView] widget.
  const PasswordResetEmailStepView({super.key});

  @override
  State<PasswordResetEmailStepView> createState() => _PasswordResetEmailStepViewState();
}

class _PasswordResetEmailStepViewState extends State<PasswordResetEmailStepView> {
  final _formKey = GlobalKey<FormBuilderState>(debugLabel: 'password_reset_email_step_form');

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Column(
      children: [
        SaText(
          t.auth.passwordReset.emailStep.title,
          style: AppTextStyle.h4,
        ),
        const SizedBox(height: AppSpacing.s),
        SaText(
          t.auth.passwordReset.emailStep.subtitle,
          style: AppTextStyle.titleS,
        ),
        const SizedBox(height: AppSpacing.xl),
        FormBuilder(
          key: _formKey,
          child: SaFormTextField(
            formKeyName: 'email',
            prefixIcon: const SaIcon(
              icon: SaIconSource.huge(HugeIconsStrokeRounded.mail01),
            ),
            labelText: t.auth.common.email,
            validator: FormValidator.email(),
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) => _onSendCodePressed(),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        BlocBuilder<PasswordResetBloc, PasswordResetState>(
          builder: (_, state) {
            final isLoading = state is PasswordResetLoading;

            return SaPrimaryButton.icon(
              onPressed: _onSendCodePressed,
              isLoading: isLoading,
              iconAlignment: SaIconAlignment.end,
              label: SaText(t.auth.passwordReset.emailStep.sendButton),
              icon: const SaIcon(
                icon: SaIconSource.huge(HugeIconsStrokeRounded.sent),
              ),
            );
          },
        ),
      ],
    );
  }

  void _onSendCodePressed() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final email = _formKey.currentState?.value['email'] as String;

      final language = Translations.of(context).language;

      context.read<PasswordResetBloc>().add(
        PasswordResetRequested(
          email: email,
          emailLanguage: AppLanguage.values.byNameOrDefault(
            language.name,
            AppLanguage.system,
          ),
        ),
      );

      final t = Translations.of(context);
      ScaffoldMessengerHelper.showMessage(
        context: context,
        title: t.auth.passwordReset.title,
        subtitle: t.auth.passwordReset.emailStep.successMessage,
      );
    }
  }
}
