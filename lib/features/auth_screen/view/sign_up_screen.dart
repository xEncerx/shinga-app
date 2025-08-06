import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../domain/domain.dart';
import '../../../i18n/strings.g.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/widgets.dart';

/// Screen for user sign-up.
@RoutePage()
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
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
                title: t.auth.signUp.title,
                subtitle: t.auth.signUp.subtitle,
                actionText: t.auth.signUp.title,
                onActionPressed: _onSignUpButtonPressed,
                promptText: t.auth.signUp.promptText,
                promptActionText: t.auth.signIn.title,
                onPromptActionPressed: () => context.router.pop(),
                formFields: [
                  FormBuilderTextField(
                    name: 'username',
                    decoration: InputDecoration(
                      labelText: t.auth.common.username,
                      errorMaxLines: 2,
                    ),
                    validator: TextFieldFilterService.length(3, 20),
                  ),
                  const SizedBox(height: 10),
                  FormBuilderTextField(
                    name: 'email',
                    decoration: InputDecoration(
                      labelText: t.auth.common.email,
                      errorMaxLines: 2,
                    ),
                    validator: TextFieldFilterService.email(),
                  ),
                  const SizedBox(height: 10),
                  PasswordTextField(title: t.auth.common.password),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSignUpButtonPressed() {
    if (formKey.currentState?.saveAndValidate() ?? false) {
      final fields = formKey.currentState?.fields;
      context.read<AuthBloc>().add(
        AuthSignUpRequested(
          username: fields?['username']?.value as String,
          email: fields?['email']?.value as String,
          password: fields?['password']?.value as String,
        ),
      );
    }
  }
}
