import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../bloc/auth_bloc.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.only(right: 15),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return FilledButton(
            onPressed: state is AuthLoading ? () {} : onPressed,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: const CircleBorder(),
            ),
            child: state is AuthLoading
                ? LoadingAnimationWidget.fourRotatingDots(
                    size: 32,
                    color: Colors.white,
                  )
                : const Icon(
                    Icons.arrow_forward,
                    size: 32,
                  ),
          );
        },
      ),
    );
  }
}
