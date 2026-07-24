import 'package:system_proxy_reader/src/system_proxy_models.dart';

/// Reads the effective proxy configuration for the current user.
abstract interface class SystemProxyReader {
  /// Reads a snapshot of the current proxy configuration.
  ///
  /// Throws [SystemProxyReadException] when the platform API cannot read the
  /// configuration.
  SystemProxySettings read();
}
