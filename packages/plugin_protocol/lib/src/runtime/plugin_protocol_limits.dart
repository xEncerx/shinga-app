/// Hard ceilings shared by inspection, invocation, and host-call validation.
abstract final class PluginProtocolLimits {
  /// The only invocation and host-call protocol version in this release.
  static const int protocolVersion = 1;

  /// The only Plugin API version dispatched by this release.
  static const int pluginApiVersion = 1;

  /// Maximum serialized invocation input bytes, inclusive.
  static const int maxInputBytes = 256 * 1024;

  /// Maximum serialized invocation output bytes, inclusive.
  static const int maxOutputBytes = 256 * 1024;

  /// Maximum serialized bytes in one complete host-call envelope, inclusive.
  static const int maxHostCallBytes = 256 * 1024;

  /// Maximum JSON container nesting below the root, inclusive.
  static const int maxJsonDepth = 32;

  /// Maximum JSON values and containers visited, inclusive.
  static const int maxJsonNodes = 10000;

  /// Maximum entries in one list or map, inclusive.
  static const int maxCollectionLength = 1000;

  /// Maximum UTF-8 bytes in one JSON string or object key, inclusive.
  static const int maxStringBytes = 64 * 1024;

  /// Maximum host calls created by one invocation, inclusive.
  static const int maxTotalHostCalls = 256;

  /// Maximum simultaneously pending host calls, inclusive.
  static const int maxPendingHostCalls = 32;

  /// Maximum UTF-8 bytes in a host operation or call identifier, inclusive.
  static const int maxIdentifierBytes = 128;
}
