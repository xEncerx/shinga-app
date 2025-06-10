import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../domain/domain.dart';

part 'favorite_event.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, Map<MangaSection, PagingState<int, Manga?>>> {
  FavoriteBloc(this.mangaRepository)
      : super({
          MangaSection.completed: PagingState<int, Manga?>(),
          MangaSection.reading: PagingState<int, Manga?>(),
          MangaSection.onFuture: PagingState<int, Manga?>(),
        }) {
    on<FetchNextMangaPage>(_onFetchNextMangaPage);
    on<RefreshAllSections>(_onRefreshAllSections);
    on<ClearFavoriteState>(_onClearFavoriteState);
    on<SortFavoriteManga>(_onSortFavoriteState);
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
      final newItems = await mangaRepository.getUserManga(
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
      final manga = newItems.right.content
          .map(
            (item) => item?.copyWith(isSaved: true),
          )
          .toList();

      emit({
        ...state,
        event.section: updatedSectionState.copyWith(
          pages: [...?sectionState.pages, manga],
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
    RefreshAllSections event,
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
          .map((section) => mangaRepository.getUserManga(
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
          final manga = result.right.content
            .map((manga) => manga?.copyWith(isSaved: true))
            .toList();

          newState[section] = PagingState<int, Manga?>(
            pages: [manga],
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

  void _onSortFavoriteState(
    SortFavoriteManga event,
    Emitter<Map<MangaSection, PagingState<int, Manga?>>> emit,
  ) {}

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

  final MangaRepository mangaRepository;
}
