import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pinput/pinput.dart';

import '../../../core/core.dart';
import '../../../domain/domain.dart';
import '../../../i18n/strings.g.dart';
import '../../../utils/utils.dart';
import '../auth_screen.dart';

/// Screen for resetting user password.
@RoutePage()
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  int currentState = 1;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (currentState != 1)
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: _resetState,
              icon: const Icon(Icons.refresh),
              tooltip: t.auth.resetPassword.startOver,
            ),
          ),
        Center(
          child: FormBuilder(
            key: formKey,
            child: BlocListener<AuthBloc, AuthState>(
              listener: (_, state) {
                if (state is AuthRecoverCodeSent) {
                  showSnackBar(context, t.auth.notify.resetCodeSent);
                  setState(() => currentState = 2);
                } else if (state is AuthRecoverCodeVerified) {
                  setState(() => currentState = 3);
                } else if (state is AuthPasswordResetSuccess) {
                  // Reset all fields and go back to sign-in screen
                  context.router.navigatePath('sign-in');
                  _resetState();
                }
              },
              child: Builder(
                builder: (_) {
                  switch (currentState) {
                    case 2:
                      return _buildCodeEnterContent();
                    case 3:
                      return _buildResetEnterContent();
                    default:
                      return _buildEmailEnterContent();
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailEnterContent() {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      children: [
        Text(
          t.auth.resetPassword.title,
          style: theme.textTheme.titleLarge.semiBold,
        ),
        Text(
          t.auth.resetPassword.subtitle,
          style: theme.textTheme.bodyMedium.withColor(theme.hintColor),
        ),
        const SizedBox(height: 20),
        AuthTextField(
          name: 'email',
          label: t.auth.common.email,
          validator: TextFieldFilterService.email(),
        ),
        const SizedBox(height: 20),
        AuthActionButton(
          text: t.auth.resetPassword.sendCode,
          onPressed: _onSendResetCodeButtonPressed,
        ),
      ],
    );
  }

  Widget _buildCodeEnterContent() {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      children: [
        Text(
          t.auth.resetPassword.title,
          style: theme.textTheme.titleLarge.semiBold,
        ),
        Text(
          t.auth.resetPassword.subtitle,
          style: theme.textTheme.bodyMedium.withColor(theme.hintColor),
        ),
        const SizedBox(height: 20),
        Text(
          t.auth.resetPassword.codeHint,
          style: theme.textTheme.bodyMedium.semiBold,
        ),
        const SizedBox(height: 10),
        FormBuilderField(
          name: 'code',
          builder: (field) => Pinput(
            length: 6,
            autofocus: true,
            defaultPinTheme: PinTheme(
              width: 42,
              height: 46,
              textStyle: theme.textTheme.titleLarge.semiBold.withColor(theme.colorScheme.onSurface),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.primary),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onCompleted: (value) => field.didChange(value),
            validator: TextFieldFilterService.resetCode(),
            errorTextStyle: theme.textTheme.bodySmall.withColor(theme.colorScheme.error),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 5,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(t.auth.resetPassword.emailNotReceived),
            TextButton(
              onPressed: () => _onSendResetCodeButtonPressed(skipValidation: true),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(t.auth.resetPassword.resendCode),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AuthActionButton(
          text: t.auth.resetPassword.checkCode,
          onPressed: _onVerifyCodeButtonPressed,
        ),
      ],
    );
  }

  Widget _buildResetEnterContent() {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      children: [
        Text(
          t.auth.resetPassword.title,
          style: theme.textTheme.titleLarge.semiBold,
        ),
        Text(
          t.auth.resetPassword.subtitle,
          style: theme.textTheme.bodyMedium.withColor(theme.hintColor),
        ),
        const SizedBox(height: 20),
        AuthTextField(
          name: 'newPassword',
          label: t.auth.common.newPassword,
          isPassword: true,
          validator: TextFieldFilterService.password(),
        ),
        const SizedBox(height: 20),
        AuthActionButton(
          text: t.auth.resetPassword.recoverPassword,
          onPressed: _onResetButtonPressed,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 5,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(t.auth.resetPassword.rememberedPassword),
            TextButton(
              onPressed: () => context.router.navigatePath('sign-in'),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(t.auth.signIn.title),
            ),
          ],
        ),
      ],
    );
  }

  void _onSendResetCodeButtonPressed({bool skipValidation = false}) {
    bool shouldProceed = skipValidation;

    if (!skipValidation) {
      shouldProceed = formKey.currentState?.saveAndValidate() ?? false;
    }

    if (shouldProceed) {
      final fields = formKey.currentState?.value;
      context.read<AuthBloc>().add(
        AuthSendRecoverCodeRequested(
          email: (fields?['email'] ?? '') as String,
        ),
      );
    }
  }

  void _onVerifyCodeButtonPressed() {
    if (formKey.currentState?.saveAndValidate() ?? false) {
      final fields = formKey.currentState?.value;
      context.read<AuthBloc>().add(
        AuthResetCodeVerifyRequested(
          code: (fields?['code'] ?? '') as String,
          email: (fields?['email'] ?? '') as String,
        ),
      );
    }
  }

  void _onResetButtonPressed() {
    if (formKey.currentState?.saveAndValidate() ?? false) {
      final fields = formKey.currentState?.value;
      context.read<AuthBloc>().add(
        AuthResetPasswordRequested(
          code: (fields?['code'] ?? '') as String,
          email: (fields?['email'] ?? '') as String,
          newPassword: (fields?['newPassword'] ?? '') as String,
        ),
      );
    }
  }

  void _resetState() {
    setState(() {
      currentState = 1;
      // Recreate form key to reset current state
      formKey = GlobalKey<FormBuilderState>();
    });
  }
}
