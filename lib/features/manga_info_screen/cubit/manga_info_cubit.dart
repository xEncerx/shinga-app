import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:talker/talker.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../domain/domain.dart';
import '../../features.dart';

part 'manga_info_state.dart';

class MangaInfoCubit extends Cubit<MangaInfoState> {
  MangaInfoCubit() : super(MangaInfoInitial());

  Future<void> loadMangaInfo(Manga mangaData) async {
    if (mangaData.isSaved) {
      emit(MangaInfoLoaded(mangaData));
      return;
    }

    emit(MangaInfoLoading(isMangaData: true));

    final result = await _mangaRepository.search(
      query: mangaData.slug,
      source: MangaSource.fromName(mangaData.sourceName),
    );

    result.fold(
      (l) {
        emit(MangaInfoError(l.message));
      },
      (r) async {
        final content = r.content[0];
        final updatedManga = (content ?? mangaData).copyWith(isSaved: true);

        emit(MangaInfoLoaded(updatedManga));

        if (content != null) {
          final createResult = await _mangaRepository.createManga(
            manga: content,
          );
          createResult.fold(
            (l) {
              if (l.message == ErrorCode.mangaAlreadyExists) {
                GetIt.I<SearchingBloc>().add(
                  RefreshSearchingResult(updatedManga),
                );
              }
              GetIt.I<Talker>().error(l.message);
            },
            (_) {
              GetIt.I<SearchingBloc>().add(
                RefreshSearchingResult(updatedManga),
              );
            },
          );
        }
      },
    );
  }

  Future<void> updateMangaSection(Manga mangaData, MangaSection newSection) async {
    emit(MangaInfoLoading());

    final result = await _mangaRepository.updateMangaData(
      mangaId: mangaData.id,
      section: newSection,
    );
    result.fold(
      (l) {
        emit(MangaInfoError(l.message));
      },
      (r) {
        emit(MangaInfoSectionUpdated(newSection));
        GetIt.I<FavoriteBloc>().add(RefreshAllSections());
        GetIt.I<SearchingBloc>().add(
          RefreshSearchingResult(
            mangaData.copyWith(section: newSection),
          ),
        );
      },
    );
  }

  Future<void> updateMangaUrl(Manga mangaData, String newUrl) async {
    emit(MangaInfoLoading());

    final result = await _mangaRepository.updateMangaData(
      mangaId: mangaData.id,
      currentUrl: newUrl,
    );
    result.fold(
      (l) {
        emit(MangaInfoError(l.message));
      },
      (r) {
        emit(MangaInfoUrlUpdated());
        GetIt.I<FavoriteBloc>().add(RefreshAllSections());
        GetIt.I<SearchingBloc>().add(
          RefreshSearchingResult(
            mangaData.copyWith(currentUrl: newUrl),
          ),
        );
      },
    );
  }

  final _mangaRepository = GetIt.I<MangaRepository>();
}
