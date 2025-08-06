import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../domain/domain.dart';

class PasswordTextField extends StatefulWidget {
  const PasswordTextField({super.key, required this.title});

  final String title;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormBuilderTextField(
      name: 'password',
      decoration: InputDecoration(
        labelText: widget.title,
        errorMaxLines: 2,
        suffixIcon: IconButton(
          onPressed: () => setState(() => _isObscured = !_isObscured),
          icon: Icon(
            _isObscured ? Icons.visibility : Icons.visibility_off,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      obscureText: _isObscured,
      validator: TextFieldFilterService.password(),
    );
  }
}
