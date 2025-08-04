part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable{
  @override
  List<Object?> get props => [];
}

final class LoadUserProfile extends ProfileEvent {}

final class UploadUserAvatar extends ProfileEvent{
  UploadUserAvatar(this.imageData);

  final Uint8List imageData;

  @override
  List<Object?> get props => [imageData];
}
