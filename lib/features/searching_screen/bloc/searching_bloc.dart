import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../data/data.dart';
import '../../../domain/domain.dart';

part 'searching_event.dart';
part 'searching_state.dart';

class SearchingBloc extends Bloc<SearchingEvent, SearchingState> {
  SearchingBloc() : super(SearchingInitial()) {
    on<SearchManga>(
      (event, emit) async {
        if (state is! SearchingMangaLoaded) {
          emit(SearchingStateLoading());
        }

        lastSearchQuery = event.value;
        final result = await _mangaRepository.globalSearch(
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
          emit(SearchingStateLoading());
          
          if (lastSearchQuery.isNotEmpty) {
            final result = await _mangaRepository.globalSearch(
              query: lastSearchQuery,
              limit: _searchingLimit,
            );
            
            result.fold(
              (l) => emit(SearchingError(error: l.message)),
              (r) => emit(SearchingMangaLoaded(r.content)),
            );
          } else {
            emit(currentState);
          }
        }
      }
    );

    on<AddSearchingHistoryValue>(
      (event, emit) async {
        await _historyRepository.addToSearchHistory(
          value: event.value,
        );
      },
    );

    on<ClearSearchingHistory>(
      (event, emit) async {
        await _historyRepository.clearSearchHistory();
        emit(
          const SearchingHistoryLoaded([]),
        );
      },
    );

    on<LoadSearchingHistory>(
      (event, emit) {
        emit(
          SearchingHistoryLoaded(
            _historyRepository.getSearchHistory(),
          ),
        );
      },
    );
  }

  final _historyRepository = GetIt.I<SearchHistoryRepository>();
  final _mangaRepository = GetIt.I<MangaRepository>();
  static const _searchingLimit = 20;
  String lastSearchQuery = '';
}
