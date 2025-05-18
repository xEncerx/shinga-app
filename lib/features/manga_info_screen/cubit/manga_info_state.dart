part of 'manga_info_cubit.dart';

sealed class MangaInfoState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class MangaInfoInitial extends MangaInfoState {}

final class MangaInfoLoading extends MangaInfoState {
  MangaInfoLoading({this.isMangaData = false});

  final bool isMangaData;

  @override
  List<Object?> get props => [isMangaData];
}

final class MangaInfoLoaded extends MangaInfoState {
  MangaInfoLoaded(this.manga);

  final Manga manga;

  @override
  List<Object?> get props => [manga];
}

final class MangaInfoUrlUpdated extends MangaInfoState {}

final class MangaInfoSectionUpdated extends MangaInfoState {
  MangaInfoSectionUpdated(this.newSection);

  final MangaSection newSection;

  @override
  List<Object?> get props => [newSection];
}

final class MangaInfoError extends MangaInfoState {
  MangaInfoError(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}
