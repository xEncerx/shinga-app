part of 'favorite_bloc.dart';

sealed class FavoriteEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class FetchNextMangaPage extends FavoriteEvent {
  FetchNextMangaPage({
    this.section = MangaSection.any,
    this.pageSize = ApiConstants.defaultLimit,
  });

  final int pageSize;
  final MangaSection section;

  @override
  List<Object?> get props => [pageSize, section];
}

final class RefreshAllSections extends FavoriteEvent {
  RefreshAllSections({
    this.pageSize = ApiConstants.defaultLimit,
    this.completer,
  });

  final int pageSize;
  final Completer<void>? completer;

  @override
  List<Object?> get props => [pageSize, completer];
}

final class SortFavoriteManga extends FavoriteEvent {
  SortFavoriteManga({
    required this.sortBy,
    required this.order,
  });

  final SortingEnum sortBy;
  final SortingOrder order;

  @override
  List<Object?> get props => [sortBy, order];
}

class ClearFavoriteState extends FavoriteEvent {
  @override
  List<Object?> get props => [];
}
