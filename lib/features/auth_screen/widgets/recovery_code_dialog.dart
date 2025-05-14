import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../i18n/strings.g.dart';

class RecoveryCodeDialog extends StatelessWidget {
  const RecoveryCodeDialog({
    super.key,
    required this.recoveryCode,
  });

  final String recoveryCode;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t.auth.recoverPassword.alertTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t.auth.recoverPassword.saveIt),
          const SizedBox(height: 16),
          SelectableText(
            recoveryCode,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () async => _copyToClipboard(context),
          child: Text(t.auth.button.copyToClipboard),
        ),
      ],
    );
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: recoveryCode));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.auth.recoverPassword.codeCopied),
        ),
      );
      Navigator.of(context).pop();
    }
  }
}
