part of 'search_filter_bloc.dart';

sealed class SearchFilterState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class SearchFilterInitial extends SearchFilterState {}


final class FilterDataLoaded extends SearchFilterState {
  FilterDataLoaded({
    this.types = const [],
    this.genres = const [],
    this.statuses = const [],
  });

  final List<TitleType> types;
  final List<String> genres;
  final List<TitleStatus> statuses;

  @override
  List<Object?> get props => [types, genres, statuses];
}
