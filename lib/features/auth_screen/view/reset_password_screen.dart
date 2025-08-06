import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../domain/domain.dart';
import '../../../i18n/strings.g.dart';
import '../auth_screen.dart';

/// Screen for resetting user password.
@RoutePage()
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              AuthFormContainer(
                formKey: formKey,
                title: t.auth.resetPassword.title,
                subtitle: t.auth.resetPassword.subtitle,
                actionText: t.auth.resetPassword.reset,
                onActionPressed: _onResetButtonPressed,
                formFields: [
                  FormBuilderTextField(
                    name: 'code',
                    decoration: InputDecoration(
                      labelText: t.auth.resetPassword.resetCode,
                      errorMaxLines: 2,
                    ),
                    validator: TextFieldFilterService.resetCode(),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  const ResetEmailTextField(),
                  const SizedBox(height: 10),
                  PasswordTextField(title: t.auth.common.newPassword),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onResetButtonPressed() {
    if (formKey.currentState?.saveAndValidate() ?? false) {
      final fields = formKey.currentState?.fields;
      context.read<AuthBloc>().add(
        AuthResetPasswordRequested(
          code: fields?['code']?.value as String,
          email: fields?['email']?.value as String,
          newPassword: fields?['password']?.value as String,
        ),
      );
    }
  }
}
