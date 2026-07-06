import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/domain/domain.dart';

part 'user_entity.freezed.dart';

/// A domain entity representing an authenticated user.
@freezed
abstract class UserEntity with _$UserEntity {
  /// Creates a [UserEntity] instance.
  const factory UserEntity({
    /// The unique identifier of the user.
    required int id,

    /// The display name of the user.
    required String username,

    /// The email address of the user.
    required String email,

    /// The URL of the user's avatar image.
    required String avatarUrl,

    /// The role assigned to the user.
    required UserRole role,

    /// An optional biographical description provided by the user.
    String? description,
  }) = _UserEntity;
}
