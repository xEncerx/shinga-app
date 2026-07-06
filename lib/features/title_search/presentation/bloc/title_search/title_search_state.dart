part of 'title_search_bloc.dart';

/// Represents the state of the title search feature.
class TitleSearchState extends Equatable {
  /// Creates a [TitleSearchState] instance.
  TitleSearchState({
    this.query = '',
    this.filter = TitleFilter.empty,
    PagingState<int, TitleWithUserDataEntity>? pagingState,
  }) : pagingState = pagingState ?? PagingState();

  /// The current search query.
  final String query;

  /// The current filter applied to the search.
  final TitleFilter filter;

  /// The paging state for the search results.
  final PagingState<int, TitleWithUserDataEntity> pagingState;

  /// Creates a copy of this state with the given fields replaced.
  TitleSearchState copyWith({
    String? query,
    TitleFilter? filter,
    PagingState<int, TitleWithUserDataEntity>? pagingState,
  }) => TitleSearchState(
    query: query ?? this.query,
    filter: filter ?? this.filter,
    pagingState: pagingState ?? this.pagingState,
  );

  @override
  List<Object?> get props => [query, filter, pagingState];
}
