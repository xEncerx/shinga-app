/// A snapshot of the current user's system proxy configuration.
final class SystemProxySettings {
  /// Creates a system proxy configuration snapshot.
  const SystemProxySettings({
    this.autoDetect = false,
    this.autoConfigUrl,
    this.proxy,
    this.proxyBypass,
  });

  /// Whether Web Proxy Auto-Discovery is enabled.
  final bool autoDetect;

  /// The configured Proxy Auto-Configuration script URL, if present.
  final String? autoConfigUrl;

  /// The manual proxy server list in the platform's native format.
  final String? proxy;

  /// The manual proxy bypass list in the platform's native format.
  final String? proxyBypass;

  /// Whether a manual proxy server is configured.
  bool get hasManualProxy => proxy != null;

  /// Whether PAC or WPAD configuration is enabled.
  bool get hasAutomaticProxy => autoDetect || autoConfigUrl != null;
}

/// An error reported while reading system proxy configuration.
final class SystemProxyReadException implements Exception {
  /// Creates a system proxy read exception.
  const SystemProxyReadException(this.message, {this.errorCode});

  /// A human-readable description of the failure.
  final String message;

  /// The platform error code, when one was reported.
  final int? errorCode;

  @override
  String toString() {
    final code = errorCode;
    return code == null
        ? 'SystemProxyReadException: $message'
        : 'SystemProxyReadException($code): $message';
  }
}
