import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:ui_kit/ui_kit.dart';

/// A tab widget displaying titles for a specific bookmark category.
class FavoriteBookmarkTab extends StatelessWidget {
  /// Creates a [FavoriteBookmarkTab] widget.
  const FavoriteBookmarkTab({
    required this.bookmark,
    super.key,
  });

  /// The bookmark category to display.
  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => context.read<FavoritesBloc>().add(FavoritesRefresh(bookmark)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s),
        child: BlocSelector<AppSettingsCubit, AppSettingsState, TitleButtonStyle>(
          selector: (state) => state.settings.titleButtonStyle,
          builder: (_, buttonStyle) => BlocBuilder<FavoritesBloc, FavoritesState>(
            buildWhen: (prev, curr) =>
                prev.pagingStateFor(bookmark) != curr.pagingStateFor(bookmark),
            builder: (context, state) => TitlePagedList(
              state: state.pagingStateFor(bookmark),
              buttonStyle: buttonStyle,
              onFetchPage: () =>
                  context.read<FavoritesBloc>().add(FavoritesFetchNextPage(bookmark)),
              onRefresh: () => context.read<FavoritesBloc>().add(FavoritesRefresh(bookmark)),
            ),
          ),
        ),
      ),
    );
  }
}
