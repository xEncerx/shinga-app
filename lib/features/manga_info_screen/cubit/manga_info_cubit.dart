import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:talker/talker.dart';

import '../../../data/data.dart';
import '../../../domain/domain.dart';

part 'manga_info_state.dart';

class MangaInfoCubit extends Cubit<MangaInfoState> {
  MangaInfoCubit() : super(MangaInfoInitial());

  Future<void> loadMangaInfo(Manga mangaData) async {
    if (mangaData.description != "No description") {
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

        emit(MangaInfoLoaded(content ?? mangaData));

        if (content != null) {
          final createResult = await _mangaRepository.createManga(
            manga: content,
          );
          createResult.fold((l) => GetIt.I<Talker>().error(l.message), (_) {});
        }
      },
    );
  }

  Future<void> updateMangaSection(String mangaId, MangaSection newSection) async {
    emit(MangaInfoLoading());

    final result = await _mangaRepository.updateMangaData(
      mangaId: mangaId,
      section: newSection,
    );
    result.fold(
      (l) {
        emit(MangaInfoError(l.message));
      },
      (r) {
        emit(MangaInfoSectionUpdated(newSection));
      },
    );
  }

  Future<void> updateMangaUrl(String mangaId, String newUrl) async {
    emit(MangaInfoLoading());

    final result = await _mangaRepository.updateMangaData(
      mangaId: mangaId,
      currentUrl: newUrl,
    );
    result.fold(
      (l) {
        emit(MangaInfoError(l.message));
      },
      (r) {
        emit(MangaInfoUrlUpdated());
      },
    );
  }

  final _mangaRepository = GetIt.I<MangaRepository>();
}
