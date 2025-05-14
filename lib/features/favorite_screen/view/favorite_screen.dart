import 'package:auto_route/auto_route.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/domain.dart';
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
                  text: MangaSection.completed.name.capitalize,
                ),
                Tab(
                  text: MangaSection.reading.name.capitalize,
                ),
                Tab(
                  text: MangaSection.onFuture.name.capitalize,
                ),
              ],
            ),
            const SizedBox(height: 5),
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
