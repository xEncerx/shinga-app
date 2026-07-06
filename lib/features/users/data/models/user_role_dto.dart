import 'package:json_annotation/json_annotation.dart';
import 'package:shinga/domain/domain.dart';

/// The role assigned to a user, determining their permissions.
@JsonEnum(valueField: 'value')
enum UserRoleDTO {
  /// A standard user with default permissions.
  user('USER'),

  /// An administrator with full system access.
  admin('ADMIN'),

  /// A moderator responsible for content moderation.
  moderator('MODERATOR'),

  /// A staff member with elevated but limited privileges.
  staff('STAFF');

  const UserRoleDTO(this.value);

  /// The string value corresponding to the enum case, matching API responses.
  final String value;

  /// Converts this DTO to the [UserRole] domain entity.
  UserRole toDomain() => switch (this) {
    UserRoleDTO.user => UserRole.user,
    UserRoleDTO.admin => UserRole.admin,
    UserRoleDTO.moderator => UserRole.moderator,
    UserRoleDTO.staff => UserRole.staff,
  };

  /// Converts a [UserRole] domain entity to this DTO.
  static UserRoleDTO fromDomain(UserRole role) => switch (role) {
    UserRole.user => UserRoleDTO.user,
    UserRole.admin => UserRoleDTO.admin,
    UserRole.moderator => UserRoleDTO.moderator,
    UserRole.staff => UserRoleDTO.staff,
  };
}
