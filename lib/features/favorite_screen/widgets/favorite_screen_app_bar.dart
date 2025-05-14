import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../i18n/strings.g.dart';

class FavoriteScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FavoriteScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      actionsPadding: const EdgeInsets.only(right: 20),
      title: ListTile(
        tileColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        onTap: () {},
        leading: Icon(
          Icons.search_rounded,
          color: theme.hintColor,
          size: 30,
        ),
        title: Text(
          t.favorite.searchManga,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.hintColor,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => context.router.pushPath("/settings"),
          icon: Icon(
            HugeIcons.strokeRoundedSettings04,
            size: 32,
            color: theme.hintColor,
          ),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
