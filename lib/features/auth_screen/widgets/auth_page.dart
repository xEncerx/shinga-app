import 'package:flutter/material.dart';

import 'decoration.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({
    super.key,
    required this.title,
    required this.formBody,
    required this.navigationButton,
    this.additionalContent,
  });

  final String title;
  final Widget formBody;
  final Widget navigationButton;
  final Widget? additionalContent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const AuthScreenDecoration(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Build Title
                  Center(
                    child: Text(
                      title,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  formBody,
                  const SizedBox(height: 10),
                  if (additionalContent != null) ...[
                    additionalContent!,
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 20),
                  navigationButton
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
