part of 'favorite_bloc.dart';

sealed class FavoriteEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class FetchNextMangaPage extends FavoriteEvent {
  FetchNextMangaPage({
    this.section = MangaSection.any,
    this.pageSize = 21,
  });

  final int pageSize;
  final MangaSection section;

  @override
  List<Object?> get props => [pageSize, section];
}

final class RefreshAllSections extends FavoriteEvent {
  RefreshAllSections({
    this.pageSize = 20,
  });

  final int pageSize;

  @override
  List<Object?> get props => [pageSize];
}

class ClearFavoriteState extends FavoriteEvent {
  @override
  List<Object?> get props => [];
}
