part of 'title_search_history_cubit.dart';

/// Base class for title search history states.
sealed class TitleSearchHistoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state before history is loaded.
final class TitleSearchHistoryInitial extends TitleSearchHistoryState {}

/// State when search history is successfully loaded.
final class TitleSearchHistoryLoaded extends TitleSearchHistoryState {
  /// Creates a [TitleSearchHistoryLoaded] state.
  TitleSearchHistoryLoaded(this.history);

  /// The list of search history items.
  final List<TitleSearchHistoryItem> history;

  @override
  List<Object?> get props => [history];
}

/// State when an error occurs while loading history.
final class TitleSearchHistoryError extends TitleSearchHistoryState {
  /// Creates a [TitleSearchHistoryError] state.
  TitleSearchHistoryError(this.failure);

  /// The failure that occurred.
  final AppFailure failure;

  @override
  List<Object?> get props => [failure];
}
