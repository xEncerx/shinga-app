import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:talker/talker.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../domain/domain.dart';
import '../../../utils/utils.dart';

part 'favorites_event.dart';

typedef PagingTitlesState = Map<BookMarkType, PagingState<int, TitleWithUserData>>;

class FavoritesBloc extends Bloc<FavoritesEvent, PagingTitlesState> {
  FavoritesBloc({required RestClient restClient})
    : _restClient = restClient,
      super(PagingTitlesState()) {
    on<FetchFavoritesTitles>(
      _onFetchTitles,
      transformer: throttleDroppable(
        duration: const Duration(milliseconds: 500),
        trailing: true,
      ),
    );
    on<RefreshFavorites>(_onRefreshFavorites);
    on<UpdateTitleInFavorites>(_onUpdateTitle);
    on<ApplyFiltersToFavorites>(_onApplyFilters);

    _initTitleUpdateListener();
  }

  final RestClient _restClient;
  StreamSubscription<TitleWithUserData>? _titleUpdateSubscription;
  TitlesFilterFields filterData = const TitlesFilterFields(perPage: perPage);
  static const int perPage = 21;

  Future<void> _onFetchTitles(
    FetchFavoritesTitles event,
    Emitter<PagingTitlesState> emit,
  ) async {
    final currentState = state[event.bookmark] ?? PagingState<int, TitleWithUserData>();
    if (currentState.isLoading) return;

    emit({
      ...state,
      event.bookmark: currentState.copyWith(isLoading: true, error: null),
    });

    try {
      final int nextPageKey = (currentState.keys?.last ?? 0) + 1;

      final response = await _restClient.users.getMyTitles(
        filterData
            .copyWith(
              page: nextPageKey,
              bookmark: event.bookmark,
              sortBy: filterData.sortBy ?? 'user_updated_at',
            )
            .toJson(),
      );

      response.fold(
        (l) {
          emit({
            ...state,
            event.bookmark: currentState.copyWith(isLoading: false, error: l),
          });
        },
        (r) {
          emit({
            ...state,
            event.bookmark: currentState.copyWith(
              isLoading: false,
              pages: [...?currentState.pages, r.content],
              keys: [...?currentState.keys, nextPageKey],
              hasNextPage: r.pagination.hasNextPage,
            ),
          });
        },
      );
    } catch (e) {
      getIt<Talker>().error(
        'Error fetching titles for ${event.bookmark}: $e',
      );
      emit({
        ...state,
        event.bookmark: currentState.copyWith(isLoading: false, error: e),
      });
    }
  }

  Future<void> _onRefreshFavorites(
    RefreshFavorites event,
    Emitter<PagingTitlesState> emit,
  ) async {
    final currentState = state[event.bookmark] ?? PagingState<int, TitleWithUserData>();
    emit({
      ...state,
      event.bookmark: currentState.reset(),
    });
  }

  Future<void> _onApplyFilters(
    ApplyFiltersToFavorites event,
    Emitter<PagingTitlesState> emit,
  ) async {
    filterData = event.filterData;

    for (final bookmark in BookMarkType.aValues) {
      add(RefreshFavorites(bookmark));
    }
  }

  void _initTitleUpdateListener() {
    _titleUpdateSubscription = TitleUpdateService().titleUpdates.listen((updatedTitle) {
      add(UpdateTitleInFavorites(updatedTitleData: updatedTitle));
    });
  }

  Future<void> _onUpdateTitle(
    UpdateTitleInFavorites event,
    Emitter<PagingTitlesState> emit,
  ) async {
    final updatedTitle = event.updatedTitleData;
    final newState = Map<BookMarkType, PagingState<int, TitleWithUserData>>.from(state);
    bool hasChanges = false;
    final newBookmark = updatedTitle.userData?.bookmark ?? BookMarkType.notReading;

    for (final bookmarkType in BookMarkType.aValues) {
      final currentPagingState = newState[bookmarkType];

      if (currentPagingState == null ||
          currentPagingState.pages == null ||
          currentPagingState.pages!.isEmpty) {
        if (newBookmark == bookmarkType) {
          newState[bookmarkType] = PagingState<int, TitleWithUserData>();
          hasChanges = true;
        }
        continue;
      }

      final originalFlat = currentPagingState.pages!.expand((p) => p).toList();
      final beforeLen = originalFlat.length;

      final flat = originalFlat.where((t) => t.title.id != updatedTitle.title.id).toList();
      final removed = flat.length != beforeLen;

      bool inserted = false;
      if (newBookmark == bookmarkType) {
        flat.insert(0, updatedTitle);
        inserted = true;
      }

      if (removed || inserted) {
        final repaged = _repage(flat, perPage);
        final keys = _rebuildKeys(repaged.length);

        newState[bookmarkType] = currentPagingState.copyWith(
          pages: repaged,
          keys: keys,
        );
        hasChanges = true;
      }
    }

    if (hasChanges) {
      emit(newState);
    }
  }

  // Helper: split flat list into pages of size [perPage]
  List<List<T>> _repage<T>(List<T> items, int perPage) {
    final pages = <List<T>>[];
    for (var i = 0; i < items.length; i += perPage) {
      pages.add(items.sublist(i, i + perPage > items.length ? items.length : i + perPage));
    }
    return pages;
  }

  // Helper: regenerate page keys as 1..N (aligns with how nextPageKey is computed)
  List<int> _rebuildKeys(int pageCount) => List<int>.generate(pageCount, (i) => i + 1);

  @override
  Future<void> close() {
    _titleUpdateSubscription?.cancel();
    return super.close();
  }
}
