import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../domain/domain.dart';

part 'favorite_event.dart';

// TODO: Extract logic from BLoC to dedicated UseCase classes

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
        ),
    };
    emit(loadingState);

    try {
      final futures = MangaSection.activeSections
          .map(
            (section) => mangaRepository.getUserManga(
              perPage: event.pageSize,
              section: section,
            ),
          )
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

      // Reset sorting order and method to default
      sortingMethod = SortingEnum.defaultValue;
      sortingOrder = SortingOrder.defaultValue;
      nameFilter = '';

      emit(newState);
    } catch (error) {
      final errorState = {
        for (final section in MangaSection.activeSections)
          section: (state[section] ?? PagingState<int, Manga?>()).copyWith(
            error: error,
            isLoading: false,
          ),
      };
      emit(errorState);
    } finally {
      event.completer?.complete();
    }
  }

  void _onSortFavoriteState(
    SortFavoriteManga event,
    Emitter<Map<MangaSection, PagingState<int, Manga?>>> emit,
  ) {
    sortingMethod = event.sortBy;
    sortingOrder = event.order;
    nameFilter = event.nameFilter ?? '';

    final sortedState = state.map((section, pagingState) {
      // If there are no pages, return the current state
      if (pagingState.pages == null || pagingState.pages!.isEmpty) {
        return MapEntry(section, pagingState);
      }

      // Combine all items from all pages into a single list
      final allMangas = <Manga?>[];
      // ignore: prefer_foreach
      for (final page in pagingState.pages!) {
        allMangas.addAll(page);
      }

      // Sort all items
      final sortedMangas = mangaSorter.sort(
        mangas: allMangas,
        sortingMethod: sortingMethod,
        sortingOrder: sortingOrder,
        nameFilter: event.nameFilter,
      );

      // Split the sorted list back into pages
      final pageSize = pagingState.pages!.first.length; // Take the size of the first page
      final newPages = <List<Manga?>>[];
      final newKeys = <int>[];

      for (int i = 0; i < sortedMangas.length; i += pageSize) {
        final endIndex = (i + pageSize < sortedMangas.length) ? i + pageSize : sortedMangas.length;
        newPages.add(sortedMangas.sublist(i, endIndex));
        newKeys.add(i ~/ pageSize + 1); // Create Keys: 1, 2, 3...
      }

      return MapEntry(
        section,
        pagingState.copyWith(
          pages: newPages,
          keys: newKeys,
        ),
      );
    });

    emit(sortedState);
  }

  void _onClearFavoriteState(
    ClearFavoriteState event,
    Emitter<Map<MangaSection, PagingState<int, Manga?>>> emit,
  ) {
    // TODO: Revise the state-clearing logic. It's not working right now.

    emit({
      MangaSection.completed: PagingState<int, Manga?>(),
      MangaSection.reading: PagingState<int, Manga?>(),
      MangaSection.onFuture: PagingState<int, Manga?>(),
    });
  }

  final MangaRepository mangaRepository;
  final mangaSorter = MangaSorter();
  SortingEnum sortingMethod = SortingEnum.defaultValue;
  SortingOrder sortingOrder = SortingOrder.defaultValue;
  String nameFilter = '';
}
