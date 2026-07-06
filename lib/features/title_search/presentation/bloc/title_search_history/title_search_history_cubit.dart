import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/title_search/domain/domain.dart';

part 'title_search_history_state.dart';

/// A cubit that manages title search history state.
class TitleSearchHistoryCubit extends Cubit<TitleSearchHistoryState> {
  /// Creates a [TitleSearchHistoryCubit] instance.
  TitleSearchHistoryCubit(this._historyRepository) : super(TitleSearchHistoryInitial());

  /// The repository used to access search history.
  final TitleSearchHistoryRepository _historyRepository;

  /// Loads the search history from the repository.
  Future<void> loadHistory() async {
    final result = await _historyRepository.getHistory();

    result.fold(
      (failure) => emit(TitleSearchHistoryError(failure)),
      (history) => emit(TitleSearchHistoryLoaded(history)),
    );
  }

  /// Adds a search query to the history.
  Future<void> addSearchQuery(String query) async {
    if (query.length < 3) return;

    final result = await _historyRepository.addItem(
      TitleSearchHistoryItem(
        query: query,
        timestamp: DateTime.now(),
      ),
      maxItems: 100,
    );

    result.fold(
      (failure) => emit(TitleSearchHistoryError(failure)),
      (_) => loadHistory(),
    );
  }

  /// Deletes a specific item from the search history.
  Future<void> deleteHistoryItem(TitleSearchHistoryItem item) async {
    final result = await _historyRepository.removeItem(item);

    result.fold(
      (failure) => emit(TitleSearchHistoryError(failure)),
      (_) => loadHistory(),
    );
  }

  /// Clears all search history.
  Future<void> clearHistory() async {
    final result = await _historyRepository.clear();

    result.fold(
      (failure) => emit(TitleSearchHistoryError(failure)),
      (_) => loadHistory(),
    );
  }
}
