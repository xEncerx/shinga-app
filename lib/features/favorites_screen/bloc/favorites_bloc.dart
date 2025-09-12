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
  FavoritesBloc({required this.restClient}) : super(PagingTitlesState()) {
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

  final RestClient restClient;
  StreamSubscription<TitleWithUserData>? _titleUpdateSubscription;
  TitlesFilterFields filterData = const TitlesFilterFields(
    perPage: perPage,
  );
  static const int perPage = 21;

  Future<void> _onFetchTitles(
    FetchFavoritesTitles event,
    Emitter<PagingTitlesState> emit,
  ) async {
    final currentState = state[event.bookmark] ?? PagingState<int, TitleWithUserData>();
    if (currentState.isLoading) return;

    emit(
      {
        ...state,
        event.bookmark: currentState.copyWith(isLoading: true, error: null),
      },
    );

    try {
      final int nextPageKey = (currentState.keys?.last ?? 0) + 1;

      final response = await restClient.users.getMyTitles(
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
          emit(
            {
              ...state,
              event.bookmark: currentState.copyWith(isLoading: false, error: l),
            },
          );
        },
        (r) {
          emit(
            {
              ...state,
              event.bookmark: currentState.copyWith(
                isLoading: false,
                pages: [...?currentState.pages, r.content],
                keys: [...?currentState.keys, nextPageKey],
                hasNextPage: r.pagination.hasNextPage,
              ),
            },
          );
        },
      );
    } catch (e) {
      getIt<Talker>().error(
        'Error fetching titles for ${event.bookmark}: $e',
      );
      emit(
        {...state, event.bookmark: currentState.copyWith(isLoading: false, error: e)},
      );
    }
  }

  Future<void> _onRefreshFavorites(
    RefreshFavorites event,
    Emitter<PagingTitlesState> emit,
  ) async {
    final currentState = state[event.bookmark] ?? PagingState<int, TitleWithUserData>();

    emit(
      {
        ...state,
        event.bookmark: currentState.reset(),
      },
    );
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

    for (final bookmarkType in BookMarkType.aValues) {
      final currentPagingState = newState[bookmarkType];
      if (currentPagingState?.pages == null || currentPagingState!.pages!.isEmpty) {
        continue;
      }

      bool titleFoundInSection = false;
      final updatedPages = <List<TitleWithUserData>>[];

      for (final page in currentPagingState.pages!) {
        final updatedPage = <TitleWithUserData>[];

        for (final title in page) {
          if (title.title.id == updatedTitle.title.id) {
            titleFoundInSection = true;

            final oldBookmark = title.userData?.bookmark ?? BookMarkType.notReading;
            final newBookmark = updatedTitle.userData?.bookmark ?? BookMarkType.notReading;

            if (oldBookmark != newBookmark) {
              if (newBookmark == bookmarkType) {
                updatedPage.add(updatedTitle);
              }
              hasChanges = true;
            } else if (bookmarkType == newBookmark) {
              updatedPage.insert(0, updatedTitle);
              hasChanges = true;
            }
          } else {
            updatedPage.add(title);
          }
        }
        updatedPages.add(updatedPage);
      }

      if (!titleFoundInSection && updatedTitle.userData?.bookmark == bookmarkType) {
        if (updatedPages.isNotEmpty) {
          updatedPages[0].insert(0, updatedTitle);
        } else {
          updatedPages.add([updatedTitle]);
        }
        hasChanges = true;
      }

      if (hasChanges && updatedPages.isNotEmpty) {
        newState[bookmarkType] = currentPagingState.copyWith(
          pages: updatedPages,
        );
      }
    }

    if (hasChanges) {
      emit(newState);
    }
  }

  @override
  Future<void> close() {
    _titleUpdateSubscription?.cancel();
    return super.close();
  }
}
