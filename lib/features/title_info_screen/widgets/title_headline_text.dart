import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../core/core.dart';
import '../../../i18n/strings.g.dart';

class TitleHeadlineText extends StatelessWidget {
  const TitleHeadlineText({
    super.key,
    required this.displayName,
    required this.nameRu,
    required this.nameEn,
    required this.altNames,
  });

  /// Name displayed based on the selected language.
  final String displayName;

  /// Russian name of the title.
  final String? nameRu;

  /// English name of the title.
  final String? nameEn;

  /// Alternative names of the title.
  final List<String> altNames;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _showAltNamesBottomSheet(context),
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
              displayName,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAltNamesBottomSheet(BuildContext context) async {
    final theme = Theme.of(context);
    await showMaterialModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      duration: const Duration(milliseconds: 300),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const DragHandle(),
                const SizedBox(height: 10),
                Text(
                  t.titleInfo.nameRu,
                  style: theme.textTheme.titleMedium,
                ),
                SelectableText(
                  nameRu ?? 'N/A',
                  style: theme.textTheme.bodyMedium.withColor(theme.hintColor),
                ),
                const Divider(),
                Text(
                  t.titleInfo.nameEn,
                  style: theme.textTheme.titleMedium,
                ),
                SelectableText(
                  nameEn ?? 'N/A',
                  style: theme.textTheme.bodyMedium.withColor(theme.hintColor),
                ),
                const Divider(),
                Text(
                  t.titleInfo.altNames,
                  style: theme.textTheme.titleMedium,
                ),
                ...altNames
                    .take(15)
                    .map(
                      (name) => SelectableText(
                        name,
                        style: theme.textTheme.bodyMedium.withColor(theme.hintColor),
                      ),
                    ),
                const SizedBox(height: 10),
                FilledButton.tonal(
                  onPressed: () => context.router.pop(),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: Text(t.common.close),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
