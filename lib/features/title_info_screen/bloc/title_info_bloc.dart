import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker/talker.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../domain/domain.dart';

part 'title_info_event.dart';
part 'title_info_state.dart';

class TitleInfoBloc extends Bloc<TitleInfoEvent, TitleInfoState> {
  TitleInfoBloc(this.restClient) : super(TitleInfoInitial()) {
    on<UpdateTitleDataEvent>(_onUpdateTitleData);
    on<FetchRecommendationsEvent>(_onFetchRecommendations);
  }

  final RestClient restClient;

  Future<void> _onUpdateTitleData(
    UpdateTitleDataEvent event,
    Emitter<TitleInfoState> emit,
  ) async {
    try {
      UserTitleData? userData = event.titleData.userData;

      // Create empty placeholder if userData is null and bookmark is provided
      if (userData == null && event.bookmark != null) {
        userData = UserTitleData(
          userId: -1,
          titleId: event.titleData.title.id,
          userRating: 0,
          currentUrl: event.newUrl ?? '',
          bookmark: event.bookmark!,
          updatedAt: DateTime.now(),
        );
      }

      final updatedTitleData = event.titleData.copyWith(
        userData: userData?.copyWith(
          bookmark: event.bookmark ?? userData.bookmark,
          currentUrl: event.newUrl ?? userData.currentUrl,
          userRating: event.userRating ?? userData.userRating,
          updatedAt: DateTime.now(),
        ),
      );

      final result = await restClient.users.updateTitle(
        titleId: updatedTitleData.title.id,
        userRating: updatedTitleData.userData?.userRating,
        currentUrl: updatedTitleData.userData?.currentUrl,
        bookmark: updatedTitleData.userData?.bookmark.value,
      );

      result.fold(
        (l) => emit(TitleInfoFailure(l)),
        (r) {
          TitleUpdateService().updateTitle(updatedTitleData);
          emit(TitleInfoLoaded(updatedTitleData));
        },
      );
    } catch (e) {
      getIt<Talker>().error('Failed to update title data: $e', StackTrace.current);
      emit(TitleInfoFailure(const ApiException()));
    }
  }

  Future<void> _onFetchRecommendations(
    FetchRecommendationsEvent event,
    Emitter<TitleInfoState> emit,
  ) async {
    emit(RecommendationsLoading());
    try {
      final result = await restClient.titles.getRecommendations(event.titleId);

      result.fold(
        (l) => emit(RecommendationsFailure(l)),
        (r) => emit(RecommendationsLoaded(r)),
      );
    } catch (e) {
      getIt<Talker>().error('Failed to fetch recommendations: $e', StackTrace.current);
      emit(RecommendationsFailure(const ApiException()));
    }
  }
}
