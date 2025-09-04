part of 'favorites_bloc.dart';

sealed class FavoritesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class FetchFavoritesTitles extends FavoritesEvent {
  FetchFavoritesTitles(this.bookmark);

  final BookMarkType bookmark;

  @override
  List<Object?> get props => [bookmark];
}

final class RefreshFavorites extends FavoritesEvent {
  RefreshFavorites(this.bookmark);

  final BookMarkType bookmark;

  @override
  List<Object?> get props => [bookmark];
}

final class ApplyFiltersToFavorites extends FavoritesEvent {
  ApplyFiltersToFavorites(this.filterData);

  final TitlesFilterFields filterData;

  @override
  List<Object?> get props => [filterData];
}

final class UpdateTitleInFavorites extends FavoritesEvent {
  UpdateTitleInFavorites({required this.updatedTitleData});

  final TitleWithUserData updatedTitleData;

  @override
  List<Object?> get props => [updatedTitleData];
}
