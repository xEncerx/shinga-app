import 'package:meta/meta.dart';
import 'package:plugin_protocol/src/runtime/internal/protocol_validation.dart';

/// Stable public categories for plugin invocation failures.
enum PluginErrorCategory {
  /// The plugin method failed.
  pluginException,

  /// A value or message violated the versioned wire contract.
  protocolViolation,

  /// The host rejected a requested operation.
  hostDenied,

  /// The invocation exceeded an execution time limit.
  timeout,

  /// The invocation exhausted an execution resource limit.
  executionLimit,

  /// The caller cancelled the invocation.
  cancelled,

  /// The runtime adapter failed outside plugin-controlled behavior.
  engineFailure,
}

/// A safe stable error that can cross the plugin boundary.
@immutable
final class PluginError {
  /// Creates an error without retaining an internal exception or stack trace.
  factory PluginError({required PluginErrorCategory category, required String code}) {
    validateIdentifier(code, 'error.code.invalid');
    return PluginError._(category: category, code: code);
  }

  const PluginError._({required this.category, required this.code});

  /// The stable failure category.
  final PluginErrorCategory category;

  /// A stable machine-readable reason within [category].
  final String code;

  /// Encodes this error as a version-neutral JSON object.
  Map<String, Object?> toJson() => <String, Object?>{
    'category': category.name,
    'code': code,
  };

  @override
  bool operator ==(Object other) {
    return other is PluginError && other.category == category && other.code == code;
  }

  @override
  int get hashCode => Object.hash(category, code);
}

/// Reports a safe protocol-validation failure.
final class PluginProtocolException implements Exception {
  /// Creates a failure identified only by [code].
  const PluginProtocolException(this.code);

  /// The stable reason for rejection.
  final String code;

  @override
  String toString() => 'Plugin protocol violation: $code';
}
