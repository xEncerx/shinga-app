import 'package:flutter/material.dart';

import 'auth_button.dart';

class AuthFormContainer extends StatelessWidget {
  const AuthFormContainer({
    super.key,
    required this.formFields,
    required this.onPressed,
  });

  final List<Widget> formFields;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 0.2,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _buildFormFieldsWithDividers(),
          ),
        ),
        AuthButton(onPressed: onPressed),
      ],
    );
  }

  List<Widget> _buildFormFieldsWithDividers() {
    final result = <Widget>[];

    for (int i = 0; i < formFields.length; i++) {
      result.add(formFields[i]);

      if (i < formFields.length - 1) {
        result.add(
          const Center(
            child: Divider(thickness: 2, height: 0),
          ),
        );
      }
    }

    return result;
  }
}
