import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../core/core.dart';
import '../../../i18n/strings.g.dart';
import '../../../utils/utils.dart';

/// A custom text field widget for authentication forms, supporting password visibility toggle and strength indicator.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.name,
    this.label,
    this.isPassword = false,
    this.showStrengthIndicator = false,
    this.validator,
  });

  /// The name of the form field (for FormBuilder).
  final String name;

  /// The label text for the text field.
  final String? label;

  /// Whether the text field is for password input.
  /// If true, a visibility toggle icon will be shown.
  final bool isPassword;

  /// Whether to show a password strength indicator below the text field.
  final bool showStrengthIndicator;

  /// A validator function for the text field.
  final FormFieldValidator<String>? validator;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  // Password values
  late bool obfuscate;
  double passwordStrength = 0;

  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    obfuscate = widget.isPassword;
    if (widget.isPassword && widget.showStrengthIndicator) {
      controller.addListener(_passwordStrengthListener);
    }
  }

  @override
  void dispose() {
    if (widget.isPassword && widget.showStrengthIndicator) {
      controller.removeListener(_passwordStrengthListener);
    }
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    return Column(
      spacing: 10,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormBuilderTextField(
          name: widget.name,
          controller: controller,
          obscureText: obfuscate,
          validator: widget.validator,
          decoration: InputDecoration(
            labelText: widget.label,
            floatingLabelStyle: theme.textTheme.titleMedium.semiBold.withColor(
              theme.colorScheme.primary,
            ),
            suffixIconColor: theme.colorScheme.onPrimary,
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () => setState(() => obfuscate = !obfuscate),
                    icon: Icon(
                      obfuscate ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : null,
          ),
        ),
        if (widget.isPassword && widget.showStrengthIndicator) ...[
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            tween: Tween<double>(
              begin: 0,
              end: passwordStrength / 100,
            ),
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 10,
              borderRadius: BorderRadius.circular(16),
              color: PasswordStrength.getStrengthColor(passwordStrength),
            ),
          ),
          Text(
            '${t.auth.passwordDetail.strength}: ${PasswordStrength.getComplexityLevel(passwordStrength).i18n}',
            style: theme.textTheme.bodyMedium.withColor(theme.hintColor),
          ),
        ],
      ],
    );
  }

  void _passwordStrengthListener() {
    final password = controller.text;
    setState(() {
      passwordStrength = PasswordStrength.calculate(password);
    });
  }
}
