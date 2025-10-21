import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:talker/talker.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../domain/domain.dart';
import '../../../i18n/strings.g.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required RestClient restClient})
    : _restClient = restClient,
      super(ProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UploadUserAvatar>(_onUploadUserAvatar);
    on<UpdateUsername>(_onUpdateUsername);

    _initTitleUpdateListener();
  }

  final RestClient _restClient;
  StreamSubscription<TitleWithUserData>? _titleUpdateSubscription;

  /// Updates user profile when a title is updated. (like charts data)
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

    final profile = await _restClient.users.getMe();
    final votes = await _restClient.users.getMyVotes();

    profile.fold(
      (failure) => emit(ProfileFailure(failure)),
      (userData) {
        votes.fold(
          (failure) => emit(ProfileFailure(failure)),
          (userVotes) => emit(
            ProfileLoaded(
              userData: userData,
              userVotes: userVotes,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onUploadUserAvatar(
    UploadUserAvatar event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) {
      emit(ProfileFailure(ApiException(error: t.errors.dataNotLoaded)));
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/image.webp').create();
    file.writeAsBytesSync(event.imageData);

    final result = await _restClient.utils.uploadAvatar(
      file: file,
    );

    result.fold(
      (error) => emit(ProfileFailure(error)),
      (uploadedAvatar) {
        getIt<Talker>().debug('Avatar uploaded successfully: ${uploadedAvatar.avatar}');
        final updatedUserData = currentState.userData.copyWith(
          avatar: uploadedAvatar.avatar,
        );

        emit(
          ProfileLoaded(
            userData: updatedUserData,
            userVotes: currentState.userVotes,
          ),
        );
      },
    );
    await file.delete();
  }

  Future<void> _onUpdateUsername(
    UpdateUsername event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    final result = await _restClient.users.updateProfile(
      username: event.newUsername,
    );
    result.fold(
      (error) {
        emit(ProfileFailureNotify(error));
        emit(currentState);
      },
      (messageResponse) {
        if (currentState is ProfileLoaded) {
          final updatedUserData = currentState.userData.copyWith(
            username: event.newUsername,
          );

          emit(
            ProfileLoaded(
              userData: updatedUserData,
              userVotes: currentState.userVotes,
            ),
          );
        }
      },
    );
  }

  @override
  Future<void> close() {
    _titleUpdateSubscription?.cancel();
    return super.close();
  }
}
