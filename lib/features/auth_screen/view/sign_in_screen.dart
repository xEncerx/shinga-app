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
    final _ = TranslationProvider.of(context);

    return AuthPage(
      title: t.auth.login.title,
      formBody: AuthFormContainer(
        formFields: [
          StyledTextField(
            controller: _usernameController,
            hintText: t.auth.username,
            prefixIcon: const Icon(Icons.person),
            rightContentPadding: 35,
          ),
          StyledTextField(
            controller: _passwordController,
            hintText: t.auth.password,
            isPasswordField: true,
            rightContentPadding: 35,
          ),
        ],
        onPressed: _signIn,
      ),
      navigationButton: AuthNavigationButton(
        text: t.auth.signUp.title,
        onPressed: () => context.router.replace(
          const SignUpRoute(),
        ),
      ),
      additionalContent: _buildForgotButton(),
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
    final String? message = TFValidator.validateLoginForm(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    if (message != null) {
      TFValidator.showValidationError(context, message);
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
