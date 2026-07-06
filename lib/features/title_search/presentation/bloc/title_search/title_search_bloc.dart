import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';

part 'title_search_event.dart';
part 'title_search_state.dart';

/// A BLoC that manages the state of the title search feature.
class TitleSearchBloc extends Bloc<TitleSearchEvent, TitleSearchState> {
  /// Creates a [TitleSearchBloc] instance.
  TitleSearchBloc(this._titleRepository) : super(TitleSearchState()) {
    on<TitleSearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: titleSearchTransformer(),
    );
    on<TitleSearchFetchNextPage>(
      _onFetchNextPage,
      transformer: titleFetchPageTransformer(),
    );
    on<TitleSearchRefreshed>(_onTitleSearchRefreshed);
    on<TitleSearchFilterApplied>(_onFilterApplied);
    on<_TitleSearchTitleUpdated>(_onTitleUpdated);

    _titleUpdateSub = TitleUpdateBus.instance.updates.listen(
      (entity) => add(_TitleSearchTitleUpdated(entity)),
    );
  }

  final TitleRepository _titleRepository;
  late final StreamSubscription<TitleWithUserDataEntity> _titleUpdateSub;

  Future<void> _onSearchQueryChanged(
    TitleSearchQueryChanged event,
    Emitter<TitleSearchState> emit,
  ) async {
    final processedQuery = event.query.trim();
    if (processedQuery == state.query) return;

    emit(
      TitleSearchState(
        query: processedQuery,
        filter: state.filter,
      ),
    );

    if (processedQuery.length >= 3) {
      add(TitleSearchFetchNextPage());
    }
  }

  Future<void> _onFetchNextPage(
    TitleSearchFetchNextPage event,
    Emitter<TitleSearchState> emit,
  ) async {
    final pagingState = state.pagingState;
    if (pagingState.isLoading || pagingState.error != null || !pagingState.hasNextPage) return;

    emit(
      state.copyWith(
        pagingState: pagingState.copyWith(isLoading: true, error: null),
      ),
    );

    final nextKey = pagingState.nextIntPageKey;
    final result = await _titleRepository.searchTitles(
      query: state.query.trim(),
      filter: state.filter,
      page: nextKey,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          pagingState: pagingState.copyWith(error: failure, isLoading: false),
        ),
      ),
      (data) => emit(
        state.copyWith(
          pagingState: pagingState.copyWith(
            pages: [...?pagingState.pages, data.content],
            keys: [...?pagingState.keys, nextKey],
            hasNextPage: data.pagination.hasNextPage,
            isLoading: false,
          ),
        ),
      ),
    );
  }

  void _onTitleSearchRefreshed(
    TitleSearchRefreshed event,
    Emitter<TitleSearchState> emit,
  ) {
    emit(
      TitleSearchState(
        query: state.query,
        filter: state.filter,
      ),
    );
  }

  void _onFilterApplied(
    TitleSearchFilterApplied event,
    Emitter<TitleSearchState> emit,
  ) {
    emit(
      TitleSearchState(
        query: state.query,
        filter: event.filter,
      ),
    );

    if (state.query.trim().isEmpty && event.filter != TitleFilter.empty) {
      add(TitleSearchFetchNextPage());
    }
  }

  void _onTitleUpdated(
    _TitleSearchTitleUpdated event,
    Emitter<TitleSearchState> emit,
  ) {
    emit(
      state.copyWith(
        pagingState: state.pagingState.mapItems(
          (item) => item.title.id == event.entity.title.id ? event.entity : item,
        ),
      ),
    );
  }

  /// Closes the BLoC and cancels subscriptions.
  @override
  Future<void> close() async {
    await _titleUpdateSub.cancel();
    return super.close();
  }
}
