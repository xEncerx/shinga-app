part of 'searching_bloc.dart';

sealed class SearchingState extends Equatable {
  const SearchingState();

  @override
  List<Object?> get props => [];
}

final class SearchingInitial extends SearchingState {}

final class SearchingStateLoading extends SearchingState {}

final class SearchingError extends SearchingState {
  const SearchingError({required this.error});

  final Object error;

  @override
  List<Object?> get props => [error];
}

final class SearchingHistoryLoaded extends SearchingState {
  const SearchingHistoryLoaded(this.history);

  final List<String?> history;

  @override
  List<Object?> get props => [history];
}

final class SearchingMangaLoaded extends SearchingState {
  const SearchingMangaLoaded(this.manga);

  final List<Manga?> manga;

  @override
  List<Object?> get props => [manga];
}
