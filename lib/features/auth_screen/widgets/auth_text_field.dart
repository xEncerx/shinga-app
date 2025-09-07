import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../core/core.dart';
import '../../../i18n/strings.g.dart';
import '../../../utils/utils.dart';

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.name,
    this.label,
    this.isPassword = false,
    this.showStrengthIndicator = false,
    this.validator,
  });

  final String name;
  final String? label;
  final bool isPassword;
  final bool showStrengthIndicator;
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
          LinearProgressIndicator(
            value: passwordStrength / 100,
            color: PasswordStrength.getStrengthColor(passwordStrength),

            borderRadius: BorderRadius.circular(16),
            minHeight: 10,
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
