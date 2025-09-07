import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../../../i18n/strings.g.dart';

class AppDetail extends StatelessWidget {
  const AppDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    return Container(
      constraints: const BoxConstraints(
        minWidth: 400,
        maxWidth: 500,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.primaryColorDark,
            theme.primaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.auth.appDetail.title,
            style: theme.textTheme.headlineMedium.bold
                .height(1)
                .withColor(theme.colorScheme.onPrimary),
            maxLines: 2,
          ),
          Text(
            t.auth.appDetail.subtitle,
            maxLines: 5,
            style: TextStyle(color: theme.colorScheme.onPrimary),
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          ...t.auth.appDetail.features.map((e) => _buildFeatureItem(e, theme)),
          const Spacer(),
          Text(
            t.auth.appDetail.tip,
            maxLines: 3,
            style: theme.textTheme.bodySmall.withColor(theme.hintColor).ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, ThemeData theme) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary,
          ),
          child: Icon(
            Icons.check_rounded,
            size: 20,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            style: TextStyle(color: theme.colorScheme.onPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
