import 'package:flutter/material.dart';

/// Shows a SnackBar with the provided message.
/// If the message is null, it defaults to '???'.
void showSnackBar(BuildContext context, String? message) {
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message ?? '???',
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
      ),
    );
}
