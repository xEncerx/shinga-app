import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../core/extensions/extensions.dart';
import '../../../i18n/strings.g.dart';
import '../bloc/auth_bloc.dart';

class ResetEmailTextField extends StatefulWidget {
  const ResetEmailTextField({super.key});

  @override
  State<ResetEmailTextField> createState() => _ResetEmailTextFieldState();
}

class _ResetEmailTextFieldState extends State<ResetEmailTextField> {
  static const int _defaultCooldownSeconds = 60;

  final _fieldKey = GlobalKey<FormBuilderFieldState<dynamic, dynamic>>();
  Timer? _cooldownTimer;
  int _remainingSeconds = 0;
  bool _isOnCooldown = false;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    if (!mounted) return;

    setState(() {
      _isOnCooldown = true;
      _remainingSeconds = _defaultCooldownSeconds;
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isOnCooldown = false;
          });
        }
      }
    });
  }

  void _sendResetEmail() {
    if (_fieldKey.currentState?.validate() != true) {
      return;
    }
    final email = _fieldKey.currentState?.value as String?;
    if (email == null || email.isEmpty) {
      return;
    }

    context.read<AuthBloc>().add(
      AuthForgotPasswordRequested(email: email),
    );

    _startCooldown();
  }

  Widget _buildSuffixIcon() {
    if (_isOnCooldown) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          '${_remainingSeconds}s',
          style: Theme.of(context).textTheme.bodyMedium.withColor(
            Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    return IconButton(
      icon: Icon(
        Icons.send,
        color: Theme.of(context).colorScheme.primary,
      ),
      onPressed: _sendResetEmail,
      tooltip: t.auth.resetPassword.tooltip,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return FormBuilderTextField(
      key: _fieldKey,
      name: 'email',
      decoration: InputDecoration(
        labelText: t.auth.common.email,
        suffixIcon: _buildSuffixIcon(),
        errorMaxLines: 2,
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: t.auth.errors.emptyField),
        FormBuilderValidators.email(errorText: t.auth.errors.invalidEmail),
      ]),
      keyboardType: TextInputType.emailAddress,
    );
  }
}
