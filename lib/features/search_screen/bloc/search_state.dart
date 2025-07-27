part of 'search_bloc.dart';

sealed class SearchState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class SearchInitial extends SearchState {
  SearchInitial({this.history = const []});

  final List<String> history;

  @override
  List<Object?> get props => [history];
}

final class SearchPaginationState extends SearchState {
  SearchPaginationState(this.pagingState);

  final PagingState<int, TitleWithUserData> pagingState;

  @override
  List<Object?> get props => [pagingState];
}
