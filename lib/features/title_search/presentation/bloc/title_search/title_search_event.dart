part of 'title_search_bloc.dart';

/// Base class for all title search events.
sealed class TitleSearchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event to update the search query for title search.
final class TitleSearchQueryChanged extends TitleSearchEvent {
  /// Creates a [TitleSearchQueryChanged] event.
  TitleSearchQueryChanged(this.query);

  /// The new search query.
  final String query;

  @override
  List<Object?> get props => [query];
}

/// Event to fetch the next page of search results.
final class TitleSearchFetchNextPage extends TitleSearchEvent {}

/// Event to apply a filter to the title search.
final class TitleSearchFilterApplied extends TitleSearchEvent {
  /// Creates a [TitleSearchFilterApplied] event.
  TitleSearchFilterApplied(this.filter);

  /// The filter to apply.
  final TitleFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// Event to refresh the title search results.
final class TitleSearchRefreshed extends TitleSearchEvent {}

/// Internal event emitted when a title is updated during search.
final class _TitleSearchTitleUpdated extends TitleSearchEvent {
  _TitleSearchTitleUpdated(this.entity);

  /// The updated title entity.
  final TitleWithUserDataEntity entity;

  @override
  List<Object?> get props => [entity];
}
