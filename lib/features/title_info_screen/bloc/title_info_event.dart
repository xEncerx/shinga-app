part of 'title_info_bloc.dart';

sealed class TitleInfoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class UpdateTitleDataEvent extends TitleInfoEvent {
  UpdateTitleDataEvent({
    required this.titleData,
    this.newUrl,
    this.bookmark,
    this.userRating,
  });

  final TitleWithUserData titleData;
  final String? newUrl;
  final BookMarkType? bookmark;
  final int? userRating;

  @override
  List<Object?> get props => [
    titleData,
    newUrl,
    bookmark,
    userRating,
  ];
}
