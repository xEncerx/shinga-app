import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../data/data.dart';
import '../../../domain/domain.dart';

part 'favorite_event.dart';
part 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  FavoriteBloc() : super(FavoriteInitial()) {
    on<LoadInitialUserManga>(_onLoadInitial);
  }

  Future<void> _onLoadInitial(
    LoadInitialUserManga event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      emit(FavoriteLoading());

      final result = await GetIt.I<MangaRepository>().getUserManga(
        perPage: event.pageSize,
      );

      if (result.isLeft) {
        emit(FavoriteError(message: result.left.message));
        return;
      }

      // final message = result.right.message;
      // final totalPages = int.tryParse(message.split(':').last.trim()) ?? 1;
      final mangaList = result.right.content;

      final groupedManga = _groupMangaBySection(mangaList);

      emit(
        FavoriteLoaded(
          mangaList: mangaList,
          completedMangaList: groupedManga[MangaSection.completed] ?? [],
          readingMangaList: groupedManga[MangaSection.reading] ?? [],
          onFutureMangaList: groupedManga[MangaSection.onFuture] ?? [],
          page: 1,
        ),
      );
    } on Exception catch (e) {
      emit(FavoriteError(message: e.toString()));
    }
  }

  Map<MangaSection, List<Manga?>> _groupMangaBySection(List<Manga?> mangaList) {
    final result = <MangaSection, List<Manga?>>{};

    for (final section in MangaSection.values) {
      result[section] = mangaList.where((manga) => manga?.section == section).toList();
    }

    return result;
  }
}
