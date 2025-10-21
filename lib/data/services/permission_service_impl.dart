import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/domain.dart';

/// Implementation of [PermissionService] for Android platform.
class AndroidPermissionService implements PermissionService {
  @override
  Future<bool> requestPhotoPermission() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    late final PermissionStatus result;

    if (androidInfo.version.sdkInt < 33) {
      // For Android versions below 13, request manage external storage permission
      result = await Permission.storage.request();
    } else {
      // For Android 13 and above, request photo permission
      result = await Permission.photos.request();
    }

    return result.isGranted;
  }
}

/// Implementation of [PermissionService] for windows platform.
class WindowsPermissionService implements PermissionService {
  @override
  Future<bool> requestPhotoPermission() async {
    // Windows does not require explicit permission for photo access.
    return true;
  }
}

/// Stub implementation of [PermissionService] for unsupported platforms.
class StubPermissionService implements PermissionService {
  @override
  Future<bool> requestPhotoPermission() async {
    return false;
  }
}
