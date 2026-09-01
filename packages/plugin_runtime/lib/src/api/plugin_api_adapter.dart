/// Selects the internal transport used by one exact public Plugin API version.
abstract interface class PluginApiAdapter {
  /// The exact positive Plugin API version implemented by this adapter.
  int get pluginApiVersion;

  /// The exact internal wire protocol selected for this Plugin API.
  int get wireProtocolVersion;
}

/// The built-in Plugin API v1 mapping.
final class PluginApiV1Adapter implements PluginApiAdapter {
  /// Creates the immutable API-v1 adapter.
  const PluginApiV1Adapter();

  @override
  int get pluginApiVersion => 1;

  @override
  int get wireProtocolVersion => 1;
}
