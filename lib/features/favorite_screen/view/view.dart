import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../../../i18n/strings.g.dart';
import '../../features.dart';

@RoutePage()
class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    final _ = TranslationProvider.of(context);

    return Scaffold(
      appBar: const FavoriteScreenAppBar(),
      body: DefaultTabController(
        length: 3,
        initialIndex: 1,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabs: [
                Tab(
                  text: t.favorite.sections.completed,
                ),
                Tab(
                  text: t.favorite.sections.reading,
                ),
                Tab(
                  text: t.favorite.sections.onFuture,
                ),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  PagedFavoriteList(
                    section: MangaSection.completed,
                  ),
                  PagedFavoriteList(
                    section: MangaSection.reading,
                  ),
                  PagedFavoriteList(
                    section: MangaSection.onFuture,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
