import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../core/core.dart';
import '../../features.dart';

class AuthActionButton extends StatelessWidget {
  const AuthActionButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size.fromHeight(50),
          ),
          child: isLoading
              ? LoadingAnimationWidget.horizontalRotatingDots(
                  color: theme.colorScheme.onPrimary,
                  size: 32,
                )
              : Text(
                  text,
                  style: theme.textTheme.bodyLarge.semiBold.withColor(
                    theme.colorScheme.onPrimary,
                  ),
                ),
        );
      },
    );
  }
}
