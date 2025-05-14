import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../core/widgets/widgets.dart';
import '../../../cubit/cubit.dart';
import '../../../data/data.dart';
import '../../../domain/domain.dart';
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
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      child: BlocBuilder<FavoriteBloc, Map<MangaSection, PagingState<int, Manga?>>>(
        builder: (context, state) {
          final sectionState = state[section] ?? PagingState<int, Manga?>();

          return BlocSelector<AppSettingsCubit, AppSettingsState, bool>(
            selector: (state) => state.appSettings.isCardButtonStyle,
            builder: (context, isCardButtonStyle) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<FavoriteBloc>().add(
                        RefreshSection(),
                      );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
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
      ),
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
        itemBuilder: (_, item, __) => TileMangaButton(
          mangaData: item! as Manga,
        ),
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 5),
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
        itemBuilder: (_, item, __) => CardMangaButton(
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
