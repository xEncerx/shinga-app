import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data.dart';
import '../../../domain/domain.dart';

part 'searching_event.dart';
part 'searching_state.dart';

class SearchingBloc extends Bloc<SearchingEvent, SearchingState> {
  SearchingBloc(
    this.historyRepository,
    this.mangaRepository,
  ) : super(SearchingInitial()) {
    on<SearchManga>(
      (event, emit) async {
        if (state is! SearchingMangaLoaded) {
          emit(SearchingStateLoading());
        }

        lastSearchQuery = event.value;
        final result = await mangaRepository.globalSearch(
          query: event.value,
          limit: _searchingLimit,
        );

        result.fold(
          (l) => emit(
            SearchingError(error: result.left.message),
          ),
          (r) => emit(
            SearchingMangaLoaded(result.right.content),
          ),
        );
      },
    );

    on<RefreshSearchingResult>(
      (event, emit) async {
        final currentState = state;

        if (currentState is SearchingMangaLoaded) {
          if (lastSearchQuery.isNotEmpty) {
            final updatedList = currentState.manga.map((item) {
              if (item != null && item.id == event.updatedManga.id) {
                return event.updatedManga;
              }
              return item;
            }).toList();

            emit(SearchingMangaLoaded(updatedList));
          } else {
            emit(currentState);
          }
        }
      },
    );

    on<AddSearchingHistoryValue>(
      (event, emit) async {
        await historyRepository.addToSearchHistory(
          value: event.value,
        );
      },
    );

    on<ClearSearchingHistory>(
      (event, emit) async {
        await historyRepository.clearSearchHistory();
        emit(
          const SearchingHistoryLoaded([]),
        );
      },
    );

    on<LoadSearchingHistory>(
      (event, emit) {
        emit(
          SearchingHistoryLoaded(
            historyRepository.getSearchHistory(),
          ),
        );
      },
    );
  }

  final SearchHistoryRepository historyRepository;
  final MangaRepository mangaRepository;
  static const _searchingLimit = 20;
  String lastSearchQuery = '';
}
