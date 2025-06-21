import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/core.dart';
import '../../../i18n/strings.g.dart';

class FavoriteScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FavoriteScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      actionsPadding: const EdgeInsets.only(right: 20),
      title: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(40),
        child: ListTile(
          onTap: () => context.router.pushPath("/search"),
          tileColor: theme.appBarTheme.shadowColor,
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          leading: Icon(
            Icons.search_rounded,
            color: theme.hintColor,
            size: 24,
          ),
          title: Text(
            t.favorite.searchManga,
            maxLines: 1,
            style: theme.textTheme.titleMedium.semiBold.textColor(theme.hintColor),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => Scaffold.of(context).openEndDrawer(),
          icon: Icon(
            HugeIcons.strokeRoundedSorting01,
            size: 32,
            color: theme.hintColor,
          ),
        ),
        IconButton(
          onPressed: () => context.router.pushPath("/settings"),
          icon: Icon(
            HugeIcons.strokeRoundedSettings04,
            size: 32,
            color: theme.hintColor,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
