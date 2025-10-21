/// Defines the PermissionService interface for requesting permissions.
abstract class PermissionService {
  /// Requests photo permission from the user. Adds platform-specific implementations.
  /// 
  /// Returns true if permission is granted, false otherwise.
  Future<bool> requestPhotoPermission();
}
