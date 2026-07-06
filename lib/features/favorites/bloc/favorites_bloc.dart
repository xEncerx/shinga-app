import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

/// A BLoC that manages the state of the favorites feature.
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  /// Creates a [FavoritesBloc] instance.
  FavoritesBloc(this._titleRepository) : super(const FavoritesState()) {
    on<FavoritesFetchNextPage>(
      _onFetchNextPage,
      transformer: titleFetchPageTransformer(),
    );
    on<FavoritesFilterApplied>(_onFilterApplied);
    on<FavoritesRefresh>(_onRefresh);
    on<_FavoritesTitleUpdated>(_onTitleUpdated);

    _titleUpdateSub = TitleUpdateBus.instance.updates.listen(
      (entity) => add(_FavoritesTitleUpdated(entity)),
    );
  }

  final TitleRepository _titleRepository;
  late final StreamSubscription<TitleWithUserDataEntity> _titleUpdateSub;

  Future<void> _onFetchNextPage(
    FavoritesFetchNextPage event,
    Emitter<FavoritesState> emit,
  ) async {
    final pagingState = state.pagingStateFor(event.bookmark);
    if (pagingState.isLoading || pagingState.error != null || !pagingState.hasNextPage) return;

    emit(
      state.withPagingState(
        event.bookmark,
        pagingState.copyWith(isLoading: true, error: null),
      ),
    );

    final nextKey = pagingState.nextIntPageKey;
    final result = await _titleRepository.searchTitles(
      bookmark: event.bookmark,
      filter: state.filter,
      page: nextKey,
    );

    result.fold(
      (failure) => emit(
        state.withPagingState(
          event.bookmark,
          pagingState.copyWith(error: failure, isLoading: false),
        ),
      ),
      (data) => emit(
        state.withPagingState(
          event.bookmark,
          pagingState.copyWith(
            pages: [...?pagingState.pages, data.content],
            keys: [...?pagingState.keys, nextKey],
            hasNextPage: data.pagination.hasNextPage,
            isLoading: false,
          ),
        ),
      ),
    );
  }

  void _onRefresh(
    FavoritesRefresh event,
    Emitter<FavoritesState> emit,
  ) {
    emit(
      FavoritesState(
        pagingStates: {
          ...state.pagingStates,
          event.bookmark: PagingState(),
        },
      ),
    );
  }

  void _onFilterApplied(
    FavoritesFilterApplied event,
    Emitter<FavoritesState> emit,
  ) {
    emit(FavoritesState(filter: event.filter));
  }

  void _onTitleUpdated(
    _FavoritesTitleUpdated event,
    Emitter<FavoritesState> emit,
  ) {
    final entity = event.entity;
    final newBookmark = entity.userData!.bookmark;

    final oldBookmark = state.pagingStates.entries
        .where((e) => e.value.items?.any((i) => i.title.id == entity.title.id) ?? false)
        .map((e) => e.key)
        .firstOrNull;

    // Case 1: Adding a completely new title
    if (oldBookmark == null) {
      final currentNew = state.pagingStateFor(newBookmark);

      // If no page is loaded, ignore the event, data will be fetched from API later
      if (currentNew.pages == null) return;

      // If the list has already been loaded - add the new title "on top" (i.e. as the first page)
      final updatedNew = currentNew.copyWith(
        pages: [
          [entity],
          ...?currentNew.pages,
        ],
        keys: [0, ...?currentNew.keys],
      );

      emit(
        state.copyWith(
          pagingStates: {
            ...state.pagingStates,
            newBookmark: updatedNew,
          },
        ),
      );
      return;
    }

    // Case 2 and 3: Updating an existing title (with moving it to the top) or moving it to another bookmark
    final oldItem = state
        .pagingStateFor(oldBookmark)
        .items
        ?.firstWhere(
          (i) => i.title.id == entity.title.id,
        );
    if (oldItem == entity) return;

    // 1. Delete the title from the old list (to avoid duplicates on the existing page)
    final updatedOld = state
        .pagingStateFor(oldBookmark)
        .filterItems(
          (item) => item.title.id != entity.title.id,
        );

    // 2. Update the new tab depending on whether the bookmark changed
    if (oldBookmark == newBookmark) {
      // The title was just updated within the same tab (move to top)
      final updatedNew = updatedOld.copyWith(
        pages: [
          [entity],
          ...?updatedOld.pages,
        ],
        keys: [0, ...?updatedOld.keys],
      );

      emit(
        state.copyWith(
          pagingStates: {
            ...state.pagingStates,
            oldBookmark: updatedNew,
          },
        ),
      );
    } else {
      // Moving to a different tab
      final currentNew = state.pagingStateFor(newBookmark);

      if (currentNew.pages == null) {
        // If the new tab hasn't been loaded yet, just remove the title from the old tab
        emit(
          state.copyWith(
            pagingStates: {
              ...state.pagingStates,
              oldBookmark: updatedOld,
            },
          ),
        );
      } else {
        // If the new tab was already loaded, remove from old and add to the top of the new
        final updatedNew = currentNew.copyWith(
          pages: [
            [entity],
            ...?currentNew.pages,
          ],
          keys: [0, ...?currentNew.keys],
        );

        emit(
          state.copyWith(
            pagingStates: {
              ...state.pagingStates,
              oldBookmark: updatedOld,
              newBookmark: updatedNew,
            },
          ),
        );
      }
    }
  }

  /// Closes the BLoC and cancels subscriptions.
  @override
  Future<void> close() async {
    await _titleUpdateSub.cancel();
    return super.close();
  }
}
