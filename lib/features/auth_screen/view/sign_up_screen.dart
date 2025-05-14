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
    final theme = Theme.of(context);

    return AuthPage(
      title: t.auth.signUp.title,
      formBody: _buildSignUpBody(theme, context),
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

  Widget _buildSignUpBody(ThemeData theme, BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 40),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(100),
              bottomRight: Radius.circular(100),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 35),
                child: AuthTextField(
                  controller: _usernameController,
                  hintText: t.auth.username,
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const Center(
                child: Divider(thickness: 2, height: 0),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 35),
                child: AuthTextField(
                  controller: _passwordController,
                  hintText: t.auth.password,
                  isPasswordField: true,
                ),
              ),
              const Center(
                child: Divider(thickness: 2, height: 0),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 35),
                child: AuthTextField(
                  controller: _password2Controller,
                  hintText: t.auth.signUp.confirmPassword,
                  isPasswordField: true,
                ),
              ),
            ],
          ),
        ),
        AuthButton(onPressed: () => _signUp()),
      ],
    );
  }

  Widget _buildNotifyLabel(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 100),
      child: Text(
        t.auth.signUp.notifyMsg,
        maxLines: 2,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.hintColor,
          fontWeight: FontWeight.bold,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  void _signUp() {
    String? message = TFValidator.validatePassword(
      _passwordController.text,
    );
    message ??= TFValidator.checkOnPasswordMatch(
      _passwordController.text,
      _password2Controller.text,
    );
    message ??= TFValidator.checkOnNullOrEmpty(
      _usernameController.text,
    );

    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
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
