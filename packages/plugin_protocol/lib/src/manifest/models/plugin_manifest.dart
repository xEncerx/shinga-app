import 'package:meta/meta.dart';
import 'package:plugin_protocol/src/manifest/models/models.dart';

/// A normalized plugin manifest independent of its source format version.
@immutable
final class PluginManifest {
  /// Creates a normalized plugin manifest from already validated values.
  PluginManifest({
    required this.manifestVersion,
    required this.id,
    required this.name,
    required this.version,
    required this.pluginApiVersion,
    required this.entry,
    required this.permissions,
    required List<PluginSettingDefinition> settings,
  }) : settings = List.unmodifiable(settings);

  /// The source manifest schema version.
  final ManifestFormatVersion manifestVersion;

  /// The globally unique plugin identifier.
  final PluginId id;

  /// The user-facing plugin name.
  final String name;

  /// The plugin package version.
  final PluginVersion version;

  /// The plugin API version expected by the package.
  final PluginApiVersion pluginApiVersion;

  /// The package-relative JavaScript entry point.
  final PluginEntryPath entry;

  /// The capabilities requested by the plugin.
  final PluginPermissions permissions;

  /// The user-configurable settings in declaration order.
  final List<PluginSettingDefinition> settings;
}
