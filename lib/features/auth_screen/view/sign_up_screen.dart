import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/core.dart';
import '../../../i18n/strings.g.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/widgets.dart';

@RoutePage()
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _password2Controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _ = TranslationProvider.of(context);
    final theme = Theme.of(context);

    return AuthPage(
      title: t.auth.signUp.title,
      formBody: AuthFormContainer(
        formFields: [
          TonalTextField(
            controller: _usernameController,
            hintText: t.auth.username,
            prefixIcon: const Icon(Icons.person),
            rightContentPadding: 65,
          ),
          TonalTextField(
            controller: _passwordController,
            hintText: t.auth.password,
            isPasswordField: true,
            rightContentPadding: 65,
          ),
          TonalTextField(
            controller: _password2Controller,
            hintText: t.auth.signUp.confirmPassword,
            isPasswordField: true,
            rightContentPadding: 65,
          ),
        ],
        onPressed: _signUp,
      ),
      navigationButton: AuthNavigationButton(
        text: t.auth.login.title,
        onPressed: () => context.router.replace(
          const SignInRoute(),
        ),
        horizontalPadding: 30,
      ),
      additionalContent: _buildNotifyLabel(theme),
    );
  }

  Widget _buildNotifyLabel(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 100),
      child: Text(
        t.auth.signUp.notifyMsg,
        maxLines: 2,
        style: theme.textTheme.labelSmall.semiBold.ellipsis.textColor(theme.hintColor),
      ),
    );
  }

  void _signUp() {
    final String? message = TFValidator.validateSignUpForm(
      username: _usernameController.text,
      password: _passwordController.text,
      confirmPassword: _password2Controller.text,
    );

    if (message != null) {
      TFValidator.showValidationError(context, message);
      return;
    }

    context.read<AuthBloc>().add(
          SignUpEvent(
            username: _usernameController.text,
            password: _passwordController.text,
          ),
        );
  }
}
