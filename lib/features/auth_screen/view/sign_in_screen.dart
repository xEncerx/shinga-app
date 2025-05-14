import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../core/core.dart';
import '../../../i18n/strings.g.dart';
import '../../features.dart';
import '../widgets/widgets.dart';

@RoutePage()
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthPage(
      title: t.auth.login.title,
      formBody: _buildLoginBody(theme, context),
      navigationButton: AuthNavigationButton(
        text: t.auth.signUp.title,
        onPressed: () => context.router.replace(
          const SignUpRoute(),
        ),
      ),
      additionalContent: _buildForgotButton(),
    );
  }

  Widget _buildLoginBody(ThemeData theme, BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 40),
          padding: const EdgeInsets.only(right: 35),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(100),
              bottomRight: Radius.circular(100),
            ),
          ),
          child: Column(
            children: [
              AuthTextField(
                controller: _usernameController,
                hintText: t.auth.username,
                prefixIcon: const Icon(Icons.person),
              ),
              const Center(
                child: Divider(thickness: 2, height: 1),
              ),
              AuthTextField(
                controller: _passwordController,
                hintText: t.auth.password,
                isPasswordField: true,
              ),
            ],
          ),
        ),
        AuthButton(onPressed: () => _signIn()),
      ],
    );
  }

  Widget _buildForgotButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => showMaterialModalBottomSheet<void>(
          context: context,
          isDismissible: false,
          duration: const Duration(milliseconds: 300),
          builder: (_) => const PasswordRecoverySheet(),
        ),
        child: Text(
          t.auth.login.forgot,
        ),
      ),
    );
  }

  void _signIn() {
    String? message = TFValidator.validatePassword(
      _passwordController.text,
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
          SignInEvent(
            username: _usernameController.text,
            password: _passwordController.text,
          ),
        );
  }
}
