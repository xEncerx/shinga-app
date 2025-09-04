part of 'titles_filter_cubit.dart';

sealed class TitlesFilterState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TitlesFilterInitial extends TitlesFilterState {}

final class TitlesFilterDataLoading extends TitlesFilterState {}

final class TitlesFilterDataLoaded extends TitlesFilterState {
  TitlesFilterDataLoaded({
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
