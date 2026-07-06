part of 'favorites_bloc.dart';

/// Base class for all favorites events.
sealed class FavoritesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event to fetch the next page of favorites for a specific bookmark.
final class FavoritesFetchNextPage extends FavoritesEvent {
  /// Creates a [FavoritesFetchNextPage] event.
  FavoritesFetchNextPage(this.bookmark);

  /// The bookmark for which to fetch the next page.
  final Bookmark bookmark;

  @override
  List<Object?> get props => [bookmark];
}

/// Event to refresh favorites for a specific bookmark.
final class FavoritesRefresh extends FavoritesEvent {
  /// Creates a [FavoritesRefresh] event.
  FavoritesRefresh(this.bookmark);

  /// The bookmark to refresh.
  final Bookmark bookmark;

  @override
  List<Object?> get props => [bookmark];
}

/// Event to apply a filter to the favorites.
final class FavoritesFilterApplied extends FavoritesEvent {
  /// Creates a [FavoritesFilterApplied] event.
  FavoritesFilterApplied(this.filter);

  /// The filter to apply.
  final TitleFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// Internal event emitted when a title is updated.
final class _FavoritesTitleUpdated extends FavoritesEvent {
  _FavoritesTitleUpdated(this.entity);

  /// The updated title entity.
  final TitleWithUserDataEntity entity;

  @override
  List<Object?> get props => [entity];
}
