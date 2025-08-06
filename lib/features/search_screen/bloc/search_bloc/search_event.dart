part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class FetchSearchTitles extends SearchEvent {
  FetchSearchTitles(this.searchData);

  final SearchTitleFields searchData;

  @override
  List<Object?> get props => [searchData];
}

final class LoadMoreSearchTitles extends SearchEvent {}

final class LoadSearchHistory extends SearchEvent {}

final class ClearSearchingHistory extends SearchEvent {}

final class UpdateTitleInSearch extends SearchEvent {
  UpdateTitleInSearch({required this.updatedTitleData});

  final TitleWithUserData updatedTitleData;

  @override
  List<Object?> get props => [updatedTitleData];
}
