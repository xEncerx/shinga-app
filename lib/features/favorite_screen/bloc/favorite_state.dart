part of 'favorite_bloc.dart';

sealed class FavoriteState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class FavoriteInitial extends FavoriteState {}

final class FavoriteLoading extends FavoriteState {}

final class FavoriteLoaded extends FavoriteState {
  FavoriteLoaded({
    required this.mangaList,
    required this.page,
    this.completedMangaList = const [],
    this.readingMangaList = const [],
    this.onFutureMangaList = const [],
  });

  final List<Manga?> mangaList;
  final List<Manga?> completedMangaList;
  final List<Manga?> readingMangaList;
  final List<Manga?> onFutureMangaList;
  final int page;

  @override
  List<Object?> get props => super.props
    ..addAll([
      mangaList,
      completedMangaList,
      readingMangaList,
      onFutureMangaList,
      page,
    ]);
}

final class FavoriteError extends FavoriteState {
  FavoriteError({required this.message});

  final String message;

  @override
  List<Object?> get props => super.props..add(message);
}
