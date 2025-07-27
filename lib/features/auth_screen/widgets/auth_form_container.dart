import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../core/extensions/text_theme_extension.dart';
import '../../features.dart';

class AuthFormContainer extends StatelessWidget {
  const AuthFormContainer({
    super.key,
    required this.formKey,
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.onActionPressed,
    this.promptText,
    this.promptActionText,
    this.onPromptActionPressed,
    required this.formFields,
    this.extraActionButton,
  });

  final GlobalKey<FormBuilderState> formKey;
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback onActionPressed;
  final String? promptText;
  final String? promptActionText;
  final VoidCallback? onPromptActionPressed;
  final List<Widget> formFields;
  final Widget? extraActionButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormBuilder(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineMedium.bold,
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            maxLines: 2,
            style: theme.textTheme.bodyMedium.withColor(theme.hintColor),
          ),
          const SizedBox(height: 30),
          ...formFields,
          if (extraActionButton != null) ...[
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerRight,
              child: extraActionButton,
            ),
          ],
          const SizedBox(height: 20),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return FilledButton(
                onPressed: state is AuthLoading ? null : onActionPressed,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  actionText,
                  style: theme.textTheme.bodyLarge.semiBold.withColor(theme.colorScheme.onPrimary),
                ),
              );
            },
          ),
          if (promptText != null && promptActionText != null) ...[
            const SizedBox(height: 5),
            Align(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    promptText!,
                    maxLines: 2,
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: onPromptActionPressed,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                    ),
                    child: Text(promptActionText!),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
