import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/domain/entities/entities.dart';
import 'package:shinga/features/features.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

/// A DTO representing the user profile returned by the API.
@freezed
abstract class UserDTO with _$UserDTO {
  /// Creates a [UserDTO] instance.
  const factory UserDTO({
    required int id,
    required String username,
    required String email,
    required String avatarPath,
    required UserRoleDTO role,
    String? description,
  }) = _UserDTO;

  const UserDTO._();

  /// Deserializes a [UserDTO] from [json].
  factory UserDTO.fromJson(Map<String, Object?> json) => _$UserDTOFromJson(json);

  /// Creates a [UserDTO] from a [UserEntity] domain model.
  factory UserDTO.fromDomain(UserEntity user) => UserDTO(
    id: user.id,
    username: user.username,
    email: user.email,
    avatarPath: user.avatarUrl,
    role: UserRoleDTO.fromDomain(user.role),
    description: user.description,
  );

  /// Maps this DTO to the [UserEntity] domain entity.
  UserEntity toDomain() => UserEntity(
    id: id,
    username: username,
    email: email,
    avatarUrl: avatarPath,
    role: role.toDomain(),
    description: description,
  );
}
