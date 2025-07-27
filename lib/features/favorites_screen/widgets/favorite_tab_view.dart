import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../core/widgets/titles/titles.dart';
import '../../../data/data.dart';
import '../../features.dart';

class FavoriteTabView extends StatelessWidget {
  const FavoriteTabView({
    super.key,
    required this.bookmark,
  });

  final BookMarkType bookmark;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, PagingTitlesState>(
      builder: (context, state) => RefreshIndicator(
        onRefresh: () => Future.sync(
          () => context.read<FavoritesBloc>().add(RefreshFavorites(bookmark)),
        ),
        child: PagedTitleList(
          state: state[bookmark] ?? PagingState<int, TitleWithUserData>(),
          onRefresh: () => context.read<FavoritesBloc>().add(
            RefreshFavorites(bookmark),
          ),
          onFetchPage: () => context.read<FavoritesBloc>().add(
            FetchFavoritesTitles(bookmark),
          ),
        ),
      ),
    );
  }
}
