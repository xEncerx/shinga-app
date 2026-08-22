import 'package:plugin_protocol/plugin_protocol.dart';

/// The installed state needed to evaluate replacement and permission policy.
final class InstalledPluginRecord {
  /// Creates an installed plugin descriptor.
  const InstalledPluginRecord({
    required this.id,
    required this.version,
    required this.permissions,
  });

  /// The globally unique installed plugin identifier.
  final PluginId id;

  /// The currently installed package version.
  final PluginVersion version;

  /// The permissions granted to the installed package.
  final PluginPermissions permissions;
}
