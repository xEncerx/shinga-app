import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../../../i18n/strings.g.dart';

class AltNamesBottomSheet extends StatelessWidget {
  const AltNamesBottomSheet({
    super.key,
    this.nameRu,
    this.nameEn,
    required this.altNames,
  });

  final String? nameRu;
  final String? nameEn;
  final List<String> altNames;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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
              elevation: 1,
              minimumSize: const Size(double.infinity, 45),
            ),
            child: Text(t.common.close),
          ),
        ],
      ),
    );
  }
}
