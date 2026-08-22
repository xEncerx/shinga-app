import 'package:meta/meta.dart';
import 'package:plugin_protocol/src/manifest/models/permissions/network_permission.dart';

/// The capabilities requested by a plugin.
@immutable
final class PluginPermissions {
  /// Creates plugin permissions.
  const PluginPermissions({this.network});

  /// The network permission, or `null` when network access is denied.
  final NetworkPermission? network;
}
