/// The role assigned to a user, determining their permissions.
enum UserRole {
  /// A standard user with default permissions.
  user,

  /// An administrator with full system access.
  admin,

  /// A moderator responsible for content moderation.
  moderator,

  /// A staff member with elevated but limited privileges.
  staff,
}
