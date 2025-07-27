part of 'title_info_bloc.dart';

sealed class TitleInfoState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class TitleInfoInitial extends TitleInfoState {}

final class TitleInfoLoaded extends TitleInfoState {
  TitleInfoLoaded(this.titleData);

  final TitleWithUserData titleData;

  @override
  List<Object?> get props => [titleData];
}

final class TitleInfoFailure extends TitleInfoState {
  TitleInfoFailure(this.error);

  final HttpError error;

  @override
  List<Object?> get props => [error];
}
