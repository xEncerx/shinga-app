import 'package:shinga/domain/domain.dart';
import 'package:shinga/i18n/strings.g.dart';

/// Extension on [UserRole] to resolve its localized string representation.
extension UserRoleI18n on UserRole {
  /// Returns the localized string corresponding to this [UserRole].
  String get i18n => switch (this) {
    UserRole.user => t.profile.header.role.user,
    UserRole.admin => t.profile.header.role.admin,
    UserRole.moderator => t.profile.header.role.moderator,
    UserRole.staff => t.profile.header.role.staff,
  };
}
