import 'package:meta/meta.dart';

/// A normalized hostname pattern allowed by a network permission.
@immutable
final class NetworkHostPattern {
  const NetworkHostPattern._({required this.host, required this.includeSubdomains});

  static const int _maxHostLength = 253;
  static final RegExp _labelPattern = RegExp(
    r'^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$',
  );

  /// The lowercase hostname without a wildcard prefix.
  final String host;

  /// Whether hosts below [host] are allowed instead of [host] itself.
  final bool includeSubdomains;

  /// Creates a normalized host pattern when [source] is valid.
  static NetworkHostPattern? tryParse(String source) {
    if (!_isAscii(source)) {
      return null;
    }
    final normalized = source.toLowerCase();
    final includeSubdomains = normalized.startsWith('*.');
    final host = includeSubdomains ? normalized.substring(2) : normalized;

    if (!_isValidHost(host) || host.contains('*')) {
      return null;
    }
    return NetworkHostPattern._(host: host, includeSubdomains: includeSubdomains);
  }

  /// Whether [source] is a supported exact or wildcard host pattern.
  static bool validate(String source) => tryParse(source) != null;

  /// Whether [requestedHost] is allowed by this pattern.
  bool matches(String requestedHost) {
    if (!_isAscii(requestedHost)) {
      return false;
    }
    final normalized = requestedHost.toLowerCase();
    if (!_isValidHost(normalized) || normalized.contains('*')) {
      return false;
    }
    if (!includeSubdomains) {
      return normalized == host;
    }
    return normalized.length > host.length && normalized.endsWith('.$host');
  }

  static bool _isValidHost(String value) {
    if (value.isEmpty || value.length > _maxHostLength) {
      return false;
    }
    return value.split('.').every(_labelPattern.hasMatch);
  }

  static bool _isAscii(String value) => value.codeUnits.every((codeUnit) => codeUnit <= 0x7F);

  @override
  bool operator ==(Object other) {
    return other is NetworkHostPattern &&
        other.host == host &&
        other.includeSubdomains == includeSubdomains;
  }

  @override
  int get hashCode => Object.hash(host, includeSubdomains);

  @override
  String toString() => includeSubdomains ? '*.$host' : host;
}
