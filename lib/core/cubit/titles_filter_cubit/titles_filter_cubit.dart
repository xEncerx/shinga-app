import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker/talker.dart';

import '../../../data/data.dart';
import '../../../i18n/strings.g.dart';
import '../../core.dart';

part 'titles_filter_state.dart';

class TitlesFilterCubit extends Cubit<TitlesFilterState> {
  TitlesFilterCubit(this._restClient) : super(TitlesFilterInitial());

  final RestClient _restClient;

  Future<void> loadFilterData() async {
    emit(TitlesFilterDataLoading());

    final language = getIt<AppSettings>().language;

    try {
      final filterData = await _restClient.utils.getAvailableGenres();
      
      filterData.fold(
        (error) => _emitErrorState(error),
        (data) {
          emit(
            TitlesFilterDataLoaded(
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
      _emitErrorState(e);
    }
  }

  void _emitErrorState(dynamic error) {
    getIt<Talker>().error('Error loading filter data: $error');
    emit(
      TitlesFilterDataLoaded(
        types: TitleType.values,
        statuses: TitleStatus.values,
      ),
    );
  }
}
