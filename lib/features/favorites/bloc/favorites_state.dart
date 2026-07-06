part of 'favorites_bloc.dart';

/// Represents the state of the favorites feature.
class FavoritesState extends Equatable {
  /// Creates a [FavoritesState] instance.
  const FavoritesState({
    this.filter = TitleFilter.userFavorites,
    this.pagingStates = const {},
  });

  /// The current filter applied to the favorites.
  final TitleFilter filter;

  /// The paging states for each bookmark.
  final Map<Bookmark, PagingState<int, TitleWithUserDataEntity>> pagingStates;

  /// Returns the paging state for the given bookmark.
  PagingState<int, TitleWithUserDataEntity> pagingStateFor(Bookmark bookmark) =>
      pagingStates[bookmark] ?? PagingState();

  /// Creates a copy of this state with the given fields replaced.
  FavoritesState copyWith({
    TitleFilter? filter,
    Map<Bookmark, PagingState<int, TitleWithUserDataEntity>>? pagingStates,
  }) => FavoritesState(
    filter: filter ?? this.filter,
    pagingStates: pagingStates ?? this.pagingStates,
  );

  /// Returns a new state with the paging state for the given bookmark updated.
  FavoritesState withPagingState(
    Bookmark bookmark,
    PagingState<int, TitleWithUserDataEntity> pagingState,
  ) => copyWith(pagingStates: {...pagingStates, bookmark: pagingState});

  @override
  List<Object?> get props => [filter, pagingStates];
}
