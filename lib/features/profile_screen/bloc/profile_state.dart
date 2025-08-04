part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  ProfileLoaded({
    required this.userData,
    required this.userVotes,
  });

  final UserData userData;
  final UserVotes userVotes;

  @override
  List<Object?> get props => [userData, userVotes];
}

final class ProfileFailure extends ProfileState {
  ProfileFailure(this.error);

  final HttpError error;

  @override
  List<Object?> get props => [error];
}
