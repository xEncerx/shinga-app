import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../../../i18n/strings.g.dart';

class ReplaceUrlDialog extends StatefulWidget {
  const ReplaceUrlDialog({
    super.key,
    required this.newUrl,
  });

  final String newUrl;

  @override
  State<ReplaceUrlDialog> createState() => _ReplaceUrlDialogState();
}

class _ReplaceUrlDialogState extends State<ReplaceUrlDialog> {
  final controller = TextEditingController();

  @override
  void initState() {
    controller.text = widget.newUrl;
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(t.titleInfo.replaceUrlDialog.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t.titleInfo.replaceUrlDialog.description),
          const SizedBox(height: 10),
          TonalTextField(
            controller: controller,
            bgColor: theme.colorScheme.secondary,
            rightContentPadding: 5,
            leftContentPadding: 5,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.common.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(controller.text);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
          ),
          child: Text(
            t.common.save,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
