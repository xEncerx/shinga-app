import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// The favorites page displaying user's bookmarked titles.
@RoutePage()
class FavoritesPage extends StatelessWidget {
  /// Creates a [FavoritesPage] widget.
  const FavoritesPage({
    super.key,
    this.initialBookmark = Bookmark.reading,
  });

  /// Initial bookmark to display when the page is opened.
  final Bookmark initialBookmark;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TitleFilterCubit>(
      lazy: false,
      create: (_) => TitleFilterCubit(context.deps.titleFilterRepository),
      child: _FavoritesView(initialBookmark),
    );
  }
}

class _FavoritesView extends StatefulWidget {
  const _FavoritesView(this.initialBookmark);

  final Bookmark initialBookmark;

  @override
  State<_FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<_FavoritesView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: widget.initialBookmark.index - 1,
      length: Bookmark.aValues.length,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(_FavoritesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tabController.index = widget.initialBookmark.index - 1;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _ = Translations.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + kTextTabBarHeight),
        child: FavoritesSearchBar(
          onTap: () => context.router.pushPath('/search'),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
            tabs: Bookmark.aValues.map((e) => Tab(text: e.i18n)).toList(),
          ),
          actions: [
            Builder(
              builder: (context) => SaIconButton(
                icon: const SaIcon(icon: SaIconSource.huge(HugeIconsStrokeRounded.filter)),
                onPressed: () =>
                    openTitleFilter(context: context, onFilterApply: _onTitleFilterApply),
              ),
            ),
          ],
        ),
      ),
      endDrawer: TitleFilterDrawer(
        onFilterApply: _onTitleFilterApply,
      ),
      endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs).copyWith(bottom: 0),
          child: TabBarView(
            controller: _tabController,
            children: Bookmark.aValues.map((e) => FavoriteBookmarkTab(bookmark: e)).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _onTitleFilterApply(TitleFilter filter) async {
    context.read<FavoritesBloc>().add(FavoritesFilterApplied(filter));
    context.router.pop();
  }
}
