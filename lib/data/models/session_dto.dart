import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/users/data/models/user_dto.dart';

/// A DTO representing a user session for persistence.
class SessionDTO {
  /// Creates a [SessionDTO] instance.
  const SessionDTO({required this.user});

  /// Creates a [SessionDTO] from a [Session] domain model.
  factory SessionDTO.fromDomain(Session session) =>
      SessionDTO(user: UserDTO.fromDomain(session.user));

  /// The authenticated user associated with this session.
  final UserDTO user;

  /// Converts this [SessionDTO] to a domain [Session].
  Session toDomain() => Session(user: user.toDomain());
}
