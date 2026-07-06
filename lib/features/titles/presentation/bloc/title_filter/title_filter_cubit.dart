import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';

part 'title_filter_state.dart';

/// Cubit that manages filter form data and the uncommitted filter draft.
///
/// Consumers call init when opening the filter UI, then mutate the draft
/// via the toggle/set methods, and finally read [TitleFilterLoaded.draft]
/// inside an `onApply` callback to propagate the result upstream.
class TitleFilterCubit extends Cubit<TitleFilterState> {
  /// Creates a [TitleFilterCubit] instance.
  TitleFilterCubit(this._repository) : super(TitleFilterInitial()) {
    unawaited(_init());
  }

  final TitleFilterRepository _repository;

  /// Loads form data from the repository and sets [TitleFilter.empty] as the draft.
  ///
  /// If data is already loaded, only the draft is reset - no network request
  /// is made, benefiting from Dio's HTTP cache.
  Future<void> _init() async {
    if (state is TitleFilterLoaded) {
      emit(
        (state as TitleFilterLoaded).copyWith(draft: TitleFilter.empty),
      );
      return;
    }

    emit(TitleFilterLoading());
    // Start all requests concurrently before awaiting.
    final genresFuture = _repository.getGenreForms();
    final categoriesFuture = _repository.getCategoryForms();
    final statusesFuture = _repository.getStatusForms();
    final typesFuture = _repository.getTypeForms();

    final genresResult = await genresFuture;
    final categoriesResult = await categoriesFuture;
    final statusesResult = await statusesFuture;
    final typesResult = await typesFuture;

    AppFailure? failure;
    genresResult.fold((f) => failure = f, (_) {});
    if (failure != null) {
      emit(TitleFilterFailure(failure: failure!));
      return;
    }
    categoriesResult.fold((f) => failure = f, (_) {});
    if (failure != null) {
      emit(TitleFilterFailure(failure: failure!));
      return;
    }
    statusesResult.fold((f) => failure = f, (_) {});
    if (failure != null) {
      emit(TitleFilterFailure(failure: failure!));
      return;
    }
    typesResult.fold((f) => failure = f, (_) {});
    if (failure != null) {
      emit(TitleFilterFailure(failure: failure!));
      return;
    }

    emit(
      TitleFilterLoaded(
        allGenres: genresResult.getOrElse((_) => []),
        allCategories: categoriesResult.getOrElse((_) => []),
        statuses: statusesResult.getOrElse((_) => []),
        types: typesResult.getOrElse((_) => []),
        draft: TitleFilter.empty,
      ),
    );
  }

  /// Sets the selected [genres] in the draft, replacing any existing selection.
  void setGenres(List<TitleGenre>? genres) {
    if (state is! TitleFilterLoaded) return;
    final currentState = state as TitleFilterLoaded;

    emit(
      currentState.copyWith(
        draft: currentState.draft.copyWith(genres: genres),
      ),
    );
  }

  /// Sets the selected [categories] in the draft, replacing any existing selection.
  void setCategories(List<TitleCategory>? categories) {
    if (state is! TitleFilterLoaded) return;
    final currentState = state as TitleFilterLoaded;

    emit(
      currentState.copyWith(
        draft: currentState.draft.copyWith(categories: categories),
      ),
    );
  }

  /// Sets the publication [type] in the draft, or clears it if `null`.
  void setType(TitleType? type) {
    if (state is! TitleFilterLoaded) return;
    final currentState = state as TitleFilterLoaded;

    final newType = type == currentState.draft.type ? null : type;
    emit(currentState.copyWith(draft: currentState.draft.copyWith(type: newType)));
  }

  /// Sets the publication [status] in the draft, or clears it if `null`.
  void setStatus(TitleStatus? status) {
    if (state is! TitleFilterLoaded) return;
    final currentState = state as TitleFilterLoaded;

    final newStatus = status == currentState.draft.status ? null : status;
    emit(currentState.copyWith(draft: currentState.draft.copyWith(status: newStatus)));
  }

  /// Sets the minimum and maximum rating in the draft.
  void setRating(int start, int end) {
    if (state is! TitleFilterLoaded) return;
    final currentState = state as TitleFilterLoaded;

    emit(
      currentState.copyWith(
        draft: currentState.draft.copyWith(minRating: start, maxRating: end),
      ),
    );
  }

  /// Sets the minimum and maximum chapters in the draft.
  void setChaptersRange(int? min, int? max) {
    if (state is! TitleFilterLoaded) return;
    final currentState = state as TitleFilterLoaded;

    emit(
      currentState.copyWith(
        draft: currentState.draft.copyWith(minChapters: min, maxChapters: max),
      ),
    );
  }

  /// Sets the sort by field in the draft, or clears it if `null`.
  void setSortBy(TitleSortBy? sortBy) {
    if (state is! TitleFilterLoaded) return;
    final currentState = state as TitleFilterLoaded;

    emit(
      currentState.copyWith(
        draft: currentState.draft.copyWith(sortBy: sortBy),
      ),
    );
  }

  /// Sets the sort order in the draft, or clears it if `null`.
  void toggleSortOrder() {
    if (state is! TitleFilterLoaded) return;
    final currentState = state as TitleFilterLoaded;

    final newSortOrder = currentState.draft.sortOrder == TitleSortOrder.ascending
        ? TitleSortOrder.descending
        : TitleSortOrder.ascending;
    emit(
      currentState.copyWith(
        draft: currentState.draft.copyWith(sortOrder: newSortOrder),
      ),
    );
  }

  /// Clears all selected genres from the draft.
  void resetGenres([List<TitleGenre>? genres]) {
    if (state is! TitleFilterLoaded) return;
    final currentState = state as TitleFilterLoaded;
    emit(
      currentState.copyWith(
        draft: currentState.draft.copyWith(genres: genres),
      ),
    );
  }

  /// Clears all selected categories from the draft.
  void resetCategories([List<TitleCategory>? categories]) {
    if (state is! TitleFilterLoaded) return;
    final currentState = state as TitleFilterLoaded;
    emit(
      currentState.copyWith(
        draft: currentState.draft.copyWith(categories: categories),
      ),
    );
  }

  /// Resets the draft to [draft] and clears all search queries.
  void reset([TitleFilter draft = TitleFilter.empty]) {
    if (state is! TitleFilterLoaded) return;

    emit(
      (state as TitleFilterLoaded).copyWith(draft: draft),
    );
  }
}
