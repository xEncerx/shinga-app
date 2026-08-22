import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/src/install/installed_plugin_record.dart';

/// Reads installed plugin state needed by installation policy.
abstract interface class InstalledPluginRegistry {
  /// Returns the installed plugin with [id], or `null` when it is absent.
  Future<InstalledPluginRecord?> find(PluginId id);
}
