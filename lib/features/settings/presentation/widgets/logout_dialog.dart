import 'package:flutter/material.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// A function that shows a logout confirmation dialog.
Future<void> showLogoutDialog(BuildContext context) async {
  await showDialog<bool>(
    context: context,
    builder: (_) => const LogoutDialog(),
  );
}

/// A dialog that confirms the user's intention to log out.
class LogoutDialog extends StatelessWidget {
  /// Creates a [LogoutDialog] widget.
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return SaConfirmationDialog(
      title: t.settings.logout.dialogTitle,
      description: t.settings.logout.dialogContent,
      cancelText: t.common.cancel,
      confirmText: t.common.yes,
      onConfirm: () async => context.deps.authRepository.logout(),
    );
  }
}
