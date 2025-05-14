import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../core/core.dart';
import '../../../i18n/strings.g.dart';
import '../bloc/auth_bloc.dart';
import 'widgets.dart';

class PasswordRecoverySheet extends StatefulWidget {
  const PasswordRecoverySheet({super.key});

  @override
  State<PasswordRecoverySheet> createState() => _PasswordRecoverySheetState();
}

class _PasswordRecoverySheetState extends State<PasswordRecoverySheet> {
  final usernameController = TextEditingController();
  final newPasswordController = TextEditingController();
  final recoveryCodeController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    newPasswordController.dispose();
    recoveryCodeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          _buildDragHandle(context),
          const SizedBox(height: 20),
          _buildTitle(context),
          const SizedBox(height: 30),
          AuthTextField(
            controller: usernameController,
            hintText: t.auth.username,
            prefixIcon: const Icon(Icons.person),
            borderRadius: 10,
            bgColor: theme.colorScheme.secondary,
            rightContentPadding: 30,
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),
          AuthTextField(
            controller: newPasswordController,
            hintText: t.auth.recoverPassword.newPassword,
            isPasswordField: true,
            borderRadius: 10,
            bgColor: theme.colorScheme.secondary,
            rightContentPadding: 30,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
          AuthTextField(
            controller: recoveryCodeController,
            hintText: t.auth.recoverPassword.recoveryCode,
            prefixIcon: const Icon(Icons.security_rounded),
            borderRadius: 10,
            bgColor: theme.colorScheme.secondary,
            rightContentPadding: 30,
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),
          const SizedBox(height: 30),
          _buildRecoveryPasswordButton(context),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildRecoveryPasswordButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return LoadingAnimationWidget.staggeredDotsWave(
            size: 38,
            color: Theme.of(context).colorScheme.primary,
          );
        }
        return FilledButton(
          onPressed: () => state is AuthLoading ? () {} : _recoverPassword(),
          child: Text(
            t.auth.button.recover,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      },
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      t.auth.recoverPassword.title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return Container(
      width: 35,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  void _recoverPassword() {
    String? message = TFValidator.validatePassword(
      newPasswordController.text,
    );
    message ??= TFValidator.checkOnNullOrEmpty(
      usernameController.text,
    );
    message ??= TFValidator.checkOnNullOrEmpty(
      recoveryCodeController.text,
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
          RecoverPasswordEvent(
            username: usernameController.text,
            newPassword: newPasswordController.text,
            recoveryCode: recoveryCodeController.text,
          ),
        );
  }
}
