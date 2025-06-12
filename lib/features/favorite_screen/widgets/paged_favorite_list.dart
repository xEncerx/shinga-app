import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../core/core.dart';
import '../../../cubit/cubit.dart';
import '../../../data/data.dart';
import '../bloc/favorite_bloc.dart';

class PagedFavoriteList extends StatelessWidget {
  const PagedFavoriteList({
    super.key,
    this.pageSize = 20,
    required this.section,
  });

  final int pageSize;
  final MangaSection section;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteBloc, Map<MangaSection, PagingState<int, Manga?>>>(
      builder: (context, state) {
        final sectionState = state[section] ?? PagingState<int, Manga?>();
        final completer = Completer<void>();

        return BlocSelector<AppSettingsCubit, AppSettingsState, bool>(
          selector: (state) => state.appSettings.isCardButtonStyle,
          builder: (context, isCardButtonStyle) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<FavoriteBloc>().add(
                  RefreshAllSections(
                    completer: completer,
                  ),
                );
                return completer.future;
              },
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: isCardButtonStyle
                    ? _CardFavoriteList(
                        sectionState: sectionState,
                        section: section,
                        pageSize: pageSize,
                      )
                    : _TileFavoriteList(
                        sectionState: sectionState,
                        section: section,
                        pageSize: pageSize,
                      ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TileFavoriteList extends StatelessWidget {
  const _TileFavoriteList({
    required this.sectionState,
    required this.section,
    required this.pageSize,
  });

  final PagingState<int, Manga?> sectionState;
  final MangaSection section;
  final int pageSize;

  @override
  Widget build(BuildContext context) {
    return PagedListView.separated(
      state: sectionState,
      fetchNextPage: () => context.read<FavoriteBloc>().add(
        FetchNextMangaPage(
          pageSize: pageSize,
          section: section,
        ),
      ),
      builderDelegate: PagedChildBuilderDelegate(
        itemBuilder: (_, item, _) => TileMangaButton(
          mangaData: item! as Manga,
        ),
      ),
      separatorBuilder: (_, _) => const SizedBox(height: 5),
    );
  }
}

class _CardFavoriteList extends StatelessWidget {
  const _CardFavoriteList({
    required this.sectionState,
    required this.section,
    required this.pageSize,
  });

  final PagingState<int, Manga?> sectionState;
  final MangaSection section;
  final int pageSize;

  @override
  Widget build(BuildContext context) {
    return PagedGridView(
      state: sectionState,
      showNewPageProgressIndicatorAsGridChild: false,
      showNewPageErrorIndicatorAsGridChild: false,
      showNoMoreItemsIndicatorAsGridChild: false,
      fetchNextPage: () => context.read<FavoriteBloc>().add(
        FetchNextMangaPage(
          pageSize: pageSize,
          section: section,
        ),
      ),
      builderDelegate: PagedChildBuilderDelegate(
        itemBuilder: (_, item, _) => CardMangaButton(
          mangaData: item! as Manga,
        ),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.62,
      ),
    );
  }
}
