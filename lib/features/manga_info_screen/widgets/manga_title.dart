import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../core/core.dart';
import '../../../i18n/strings.g.dart';

class MangaTitleInfo extends StatelessWidget {
  const MangaTitleInfo({
    super.key,
    required this.name,
    required this.altNames,
  });

  final String name;
  final String altNames;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _openBottomSheet(context),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.primary,
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Text(
              name,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openBottomSheet(BuildContext context) async {
    final theme = Theme.of(context);

    await showMaterialModalBottomSheet<void>(
      backgroundColor: theme.scaffoldBackgroundColor,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const DragHandle(),
              const SizedBox(height: 20),
              Text(
                t.titleInfo.mainName,
                style: theme.textTheme.titleMedium.semiBold,
              ),
              SelectableText(name),
              const Divider(),
              Text(
                t.titleInfo.altNames,
                style: theme.textTheme.titleMedium.semiBold,
              ),
              SelectableText(altNames),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
