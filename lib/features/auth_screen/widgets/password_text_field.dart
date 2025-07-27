import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../i18n/strings.g.dart';

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
    final t = Translations.of(context);

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
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: t.auth.errors.emptyField),
        FormBuilderValidators.minLength(
          8,
          errorText: t.auth.errors.invalidFieldLength(
            comparison: t.auth.comparison.greaterOrEqual,
            length: 8,
          ),
        ),
        FormBuilderValidators.maxLength(
          128,
          errorText: t.auth.errors.invalidFieldLength(
            comparison: t.auth.comparison.lessOrEqual,
            length: 128,
          ),
        ),
        FormBuilderValidators.hasUppercaseChars(
          errorText: t.auth.errors.invalidPasswordCharacter,
        ),
      ]),
    );
  }
}
