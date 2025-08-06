import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../core/core.dart';
import '../../features.dart';

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
      onTap: () => showMaterialModalBottomSheet<void>(
        context: context,
        builder: (context) {
          return AltNamesBottomSheet(
            nameRu: nameRu,
            nameEn: nameEn,
            altNames: altNames,
          );
        },
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.primary,
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              displayName,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge.ellipsis,
            ),
          ),
        ],
      ),
    ).clickable;
  }
}
