import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../data/data.dart';
import '../../../domain/domain.dart';

part 'favorite_event.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, Map<MangaSection, PagingState<int, Manga?>>> {
  FavoriteBloc()
      : super({
          MangaSection.completed: PagingState<int, Manga?>(),
          MangaSection.reading: PagingState<int, Manga?>(),
          MangaSection.onFuture: PagingState<int, Manga?>(),
        }) {
    on<FetchNextMangaPage>(_onFetchNextMangaPage);
    on<RefreshSection>(_onRefreshAllSections);
    on<ClearFavoriteState>(_onClearFavoriteState);
  }

  Future<void> _onFetchNextMangaPage(
    FetchNextMangaPage event,
    Emitter<Map<MangaSection, PagingState<int, Manga?>>> emit,
  ) async {
    final sectionState = state[event.section] ?? PagingState<int, Manga?>();
    if (sectionState.isLoading) return;

    final updatedSectionState = sectionState.copyWith(isLoading: true, error: null);
    emit({...state, event.section: updatedSectionState});

    try {
      final newKey = (sectionState.keys?.last ?? 0) + 1;
      final newItems = await GetIt.I<MangaRepository>().getUserManga(
        page: newKey,
        perPage: event.pageSize,
        section: event.section,
      );

      if (newItems.isLeft) {
        emit({
          ...state,
          event.section: updatedSectionState.copyWith(
            error: newItems.left.message,
            isLoading: false,
          ),
        });
        return;
      }

      final isLastPage = newItems.right.content.isEmpty;

      emit({
        ...state,
        event.section: updatedSectionState.copyWith(
          pages: [...?sectionState.pages, newItems.right.content],
          keys: [...?sectionState.keys, newKey],
          isLoading: false,
          hasNextPage: !isLastPage,
        ),
      });
    } catch (error) {
      emit({
        ...state,
        event.section: updatedSectionState.copyWith(
          error: error,
          isLoading: false,
        ),
      });
    }
  }

  Future<void> _onRefreshAllSections(
    RefreshSection event,
    Emitter<Map<MangaSection, PagingState<int, Manga?>>> emit,
  ) async {
    final loadingState = {
      for (final section in MangaSection.activeSections)
        section: (state[section] ?? PagingState<int, Manga?>()).copyWith(
          isLoading: true,
          error: null,
        )
    };
    emit(loadingState);

    try {
      final futures = MangaSection.activeSections
          .map((section) => GetIt.I<MangaRepository>().getUserManga(
                perPage: event.pageSize,
                section: section,
              ))
          .toList();

      final results = await Future.wait(futures);

      final newState = {...state};

      for (int i = 0; i < MangaSection.activeSections.length; i++) {
        final section = MangaSection.activeSections[i];
        final result = results[i];

        if (result.isLeft) {
          newState[section] = (state[section] ?? PagingState<int, Manga?>()).copyWith(
            error: result.left.message,
            isLoading: false,
          );
        } else {
          final isLastPage = result.right.content.isEmpty;
          newState[section] = PagingState<int, Manga?>(
            pages: [result.right.content],
            keys: const [1],
            hasNextPage: !isLastPage,
          );
        }
      }

      emit(newState);
    } catch (error) {
      final errorState = {
        for (final section in MangaSection.activeSections)
          section: (state[section] ?? PagingState<int, Manga?>()).copyWith(
            error: error,
            isLoading: false,
          )
      };
      emit(errorState);
    }
  }

  void _onClearFavoriteState(
    ClearFavoriteState event,
    Emitter<Map<MangaSection, PagingState<int, Manga?>>> emit,
  ) {
    emit({
      MangaSection.completed: PagingState<int, Manga?>(),
      MangaSection.reading: PagingState<int, Manga?>(),
      MangaSection.onFuture: PagingState<int, Manga?>(),
    });
  }
}
