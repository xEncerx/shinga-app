part of 'favorite_bloc.dart';

sealed class FavoriteEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class LoadInitialUserManga extends FavoriteEvent {
  LoadInitialUserManga({
    this.pageSize = 21,
  });

  final int pageSize;

  @override
  List<Object?> get props => super.props..add(pageSize);
}
