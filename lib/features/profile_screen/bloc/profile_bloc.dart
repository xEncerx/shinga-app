import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data.dart';
import '../../../domain/domain.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required this.restClient}) : super(ProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);

    _initTitleUpdateListener();
  }

  final RestClient restClient;
  StreamSubscription<TitleWithUserData>? _titleUpdateSubscription;

  /// Update user profile when a title is updated. (like charts data)
  void _initTitleUpdateListener() {
    _titleUpdateSubscription = TitleUpdateService().titleUpdates.listen((_) {
      add(LoadUserProfile());
    });
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final profile = await restClient.users.getMe();
    final votes = await restClient.users.getMyVotes();

    profile.fold(
      (failure) => emit(ProfileFailure(failure)),
      (userData) {
        votes.fold(
          (failure) => emit(ProfileFailure(failure)),
          (userVotes) => emit(ProfileLoaded(userData, userVotes)),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _titleUpdateSubscription?.cancel();
    return super.close();
  }
}
