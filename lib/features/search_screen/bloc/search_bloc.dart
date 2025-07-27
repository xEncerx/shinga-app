import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:talker/talker.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../domain/domain.dart';

part 'search_event.dart';
part 'search_state.dart';

const throttleDuration = Duration(milliseconds: 200);
EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(
    this.restClient,
    this.searchHistoryRepository,
  ) : super(SearchInitial()) {
    on<LoadSearchHistory>(_onLoadSearchEvent);
    on<FetchSearchTitles>(
      _onFetchSearchTitles,
      transformer: throttleDroppable(throttleDuration),
    );
    on<LoadMoreSearchTitles>(
      _onLoadMoreSearchTitles,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ClearSearchingHistory>(_onClearSearchingHistory);
    on<UpdateTitleInSearch>(_onUpdateTitle);

    _initTitleUpdateListener();
  }

  final RestClient restClient;
  final SearchHistoryRepository searchHistoryRepository;
  StreamSubscription<TitleWithUserData>? _titleUpdateSubscription;
  SearchTitleFields searchData = const SearchTitleFields(perPage: perPage);
  Timer? _saveHistoryTimer;
  static const int perPage = 21;

  Future<void> _onLoadSearchEvent(
    LoadSearchHistory event,
    Emitter<SearchState> emit,
  ) async {
    final history = searchHistoryRepository.getSearchHistory();
    emit(SearchInitial(history: history));
  }

  Future<void> _onFetchSearchTitles(
    FetchSearchTitles event,
    Emitter<SearchState> emit,
  ) async {
    final currentState = PagingState<int, TitleWithUserData>();

    emit(
      SearchPaginationState(
        currentState.copyWith(isLoading: true, error: null),
      ),
    );

    try {
      searchData = searchData.copyWith(
        query: event.searchData.query,
        genres: event.searchData.genres,
        status: event.searchData.status,
        type: event.searchData.type,
        minRating: event.searchData.minRating,
        maxRating: event.searchData.maxRating,
        minChapters: event.searchData.minChapters,
        maxChapters: event.searchData.maxChapters,
        sortBy: event.searchData.sortBy,
        sortOrder: event.searchData.sortOrder,
        page: 1,
        perPage: perPage,
      );

      final result = await restClient.titles.search(
        searchData.toJson(),
      );

      // Save query to history with a debounce
      if (searchData.query != null && _shouldSaveToHistory(searchData.query!)) {
        _saveHistoryTimer?.cancel();
        _saveHistoryTimer = Timer(const Duration(seconds: 1), () {
          searchHistoryRepository.addToSearchHistory(searchData.query!.trim());
        });
      }

      result.fold(
        (error) => emit(
          SearchPaginationState(
            currentState.copyWith(
              isLoading: false,
              error: error,
            ),
          ),
        ),
        (titles) => emit(
          SearchPaginationState(
            currentState.copyWith(
              pages: [titles.content],
              keys: [1],
              hasNextPage: titles.pagination.hasNextPage,
              isLoading: false,
            ),
          ),
        ),
      );
    } catch (e) {
      getIt<Talker>().error(
        'Error fetching titles in search: $e',
      );
      emit(
        SearchPaginationState(
          currentState.copyWith(
            error: e,
            isLoading: false,
          ),
        ),
      );
    }
  }

  Future<void> _onLoadMoreSearchTitles(
    LoadMoreSearchTitles event,
    Emitter<SearchState> emit,
  ) async {
    if (state is! SearchPaginationState) return;

    final currentState = (state as SearchPaginationState).pagingState;
    if (currentState.isLoading || !currentState.hasNextPage) return;

    emit(
      SearchPaginationState(currentState.copyWith(isLoading: true, error: null)),
    );

    try {
      final int nextPageKey = (currentState.keys?.last ?? 0) + 1;
      searchData = searchData.copyWith(page: nextPageKey);

      final result = await restClient.titles.search(
        searchData.toJson(),
      );

      result.fold(
        (error) => emit(
          SearchPaginationState(
            currentState.copyWith(
              error: error,
              isLoading: false,
            ),
          ),
        ),
        (response) => emit(
          SearchPaginationState(
            currentState.copyWith(
              pages: [...?currentState.pages, response.content],
              keys: [...?currentState.keys, nextPageKey],
              hasNextPage: response.pagination.hasNextPage,
              isLoading: false,
            ),
          ),
        ),
      );
    } catch (e) {
      getIt<Talker>().error(
        'Error loading more titles in search: $e',
      );
      emit(
        SearchPaginationState(
          currentState.copyWith(
            error: e,
            isLoading: false,
          ),
        ),
      );
    }
  }

  Future<void> _onUpdateTitle(
    UpdateTitleInSearch event,
    Emitter<SearchState> emit,
  ) async {
    if (state is! SearchPaginationState) return;
    final currentState = (state as SearchPaginationState).pagingState;

    if (currentState.pages == null || currentState.pages!.isEmpty) {
      return;
    }

    final updatedPages = currentState.pages!.map((page) {
      return page.map((titleWithUserData) {
        if (titleWithUserData.title.id == event.updatedTitleData.title.id) {
          return event.updatedTitleData;
        }
        return titleWithUserData;
      }).toList();
    }).toList();

    emit(SearchPaginationState(currentState.copyWith(pages: updatedPages)));
  }

  void _initTitleUpdateListener() {
    _titleUpdateSubscription = TitleUpdateService().titleUpdates.listen((updatedTitle) {
      add(UpdateTitleInSearch(updatedTitleData: updatedTitle));
    });
  }

  /// Checks if the query should be saved to history.
  bool _shouldSaveToHistory(String query) {
    if (query.length < 3) return false;
    if (query.trim().isEmpty) return false;

    return query.contains(' ') || query.length >= 4;
  }

  Future<void> _onClearSearchingHistory(
    ClearSearchingHistory event,
    Emitter<SearchState> emit,
  ) async {
    await searchHistoryRepository.clearSearchHistory();
    emit(SearchInitial());
  }

  @override
  Future<void> close() {
    _titleUpdateSubscription?.cancel();
    _saveHistoryTimer?.cancel();
    return super.close();
  }
}
