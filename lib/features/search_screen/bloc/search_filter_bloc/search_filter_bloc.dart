import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker/talker.dart';

import '../../../../core/core.dart';
import '../../../../data/data.dart';
import '../../../../i18n/strings.g.dart';

part 'search_filter_event.dart';
part 'search_filter_state.dart';

class SearchFilterBloc extends Bloc<SearchFilterEvent, SearchFilterState> {
  SearchFilterBloc({required this.restClient}) : super(SearchFilterInitial()) {
    on<LoadFilterData>(_onLoadFilterData);
  }

  final RestClient restClient;

  Future<void> _onLoadFilterData(
    LoadFilterData event,
    Emitter<SearchFilterState> emit,
  ) async {
    final language = getIt<AppSettings>().language;

    try {
      final filterData = await restClient.utils.getAvailableGenres();
      filterData.fold(
        (error) => _emitErrorState(emit, error),
        (data) {
          emit(
            FilterDataLoaded(
              types: TitleType.values,
              genres:
                  data.genres
                      .map((genre) => language == AppLocale.en ? genre.en : genre.ru)
                      .toList()
                    ..sort(),
              statuses: TitleStatus.values,
            ),
          );
        },
      );
    } catch (e) {
      _emitErrorState(emit, e);
    }
  }

  void _emitErrorState(Emitter<SearchFilterState> emit, dynamic error) {
    getIt<Talker>().error('Error loading filter data: $error');
    emit(FilterDataLoaded(
      types: TitleType.values,
      statuses: TitleStatus.values,
    ));
  }
}
