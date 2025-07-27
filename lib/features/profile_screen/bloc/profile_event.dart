part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable{
  @override
  List<Object?> get props => [];
}

final class LoadUserProfile extends ProfileEvent {}
