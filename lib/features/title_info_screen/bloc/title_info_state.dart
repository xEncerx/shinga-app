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

  final ApiException error;

  @override
  List<Object?> get props => [error];
}

final class RecommendationsLoading extends TitleInfoState {}

final class RecommendationsLoaded extends TitleInfoState {
  RecommendationsLoaded(this.recommendations);

  final TitleSearchResponse recommendations;

  @override
  List<Object?> get props => [recommendations];
}

final class RecommendationsFailure extends TitleInfoState {
  RecommendationsFailure(this.error);

  final ApiException error;

  @override
  List<Object?> get props => [error];
}
