import 'package:meta/meta.dart';
import 'package:plugin_protocol/src/runtime/plugin_error.dart';

/// A version-neutral request to invoke one plugin method.
abstract interface class PluginInvocationRequest {
  /// The caller-generated correlation identifier.
  String get invocationId;

  /// The inspected plugin identity.
  String get pluginId;

  /// The inspected plugin release version.
  String get pluginVersion;

  /// The exact Plugin API selected for this invocation.
  int get pluginApiVersion;

  /// The plugin method to execute.
  String get method;

  /// The bounded JSON-compatible input value.
  Object? get params;
}

/// A version-neutral terminal invocation outcome.
abstract interface class PluginInvocationResponse {
  /// Creates a successful transport-neutral outcome.
  factory PluginInvocationResponse.success(Object? result) = _PluginInvocationResponse.success;

  /// Creates a failed transport-neutral outcome.
  factory PluginInvocationResponse.failure(PluginError error) = _PluginInvocationResponse.failure;

  /// The result when [isSuccess] is true.
  Object? get result;

  /// The safe error when [isSuccess] is false.
  PluginError? get error;

  /// Whether this response is successful, including a successful `null` result.
  bool get isSuccess;
}

/// A version-neutral correlated request for one host operation.
abstract interface class PluginHostCallRequest {
  /// The inherited invocation identifier.
  String get invocationId;

  /// The unique call identifier within one invocation.
  String get callId;

  /// The inherited plugin identity.
  String get pluginId;

  /// The inherited exact Plugin API version.
  int get pluginApiVersion;

  /// The generic host operation name.
  String get operation;

  /// The inherited absolute invocation deadline.
  int get deadlineEpochMilliseconds;

  /// The bounded JSON-compatible operation payload.
  Object? get payload;
}

/// A version-neutral correlated host-call outcome.
abstract interface class PluginHostCallResponse {
  /// Creates a successful transport-neutral host-call outcome.
  factory PluginHostCallResponse.success({
    required String callId,
    required Object? result,
  }) = _PluginHostCallResponse.success;

  /// Creates a failed transport-neutral host-call outcome.
  factory PluginHostCallResponse.failure({
    required String callId,
    required PluginError error,
  }) = _PluginHostCallResponse.failure;

  /// The request identifier owned by this response.
  String get callId;

  /// The result when [isSuccess] is true.
  Object? get result;

  /// The safe error when [isSuccess] is false.
  PluginError? get error;

  /// Whether this response is successful, including a successful `null` result.
  bool get isSuccess;
}

@immutable
final class _PluginInvocationResponse implements PluginInvocationResponse {
  const _PluginInvocationResponse.success(this.result) : error = null;

  const _PluginInvocationResponse.failure(this.error) : result = null;

  @override
  final Object? result;

  @override
  final PluginError? error;

  @override
  bool get isSuccess => error == null;
}

@immutable
final class _PluginHostCallResponse implements PluginHostCallResponse {
  const _PluginHostCallResponse.success({required this.callId, required this.result})
    : error = null;

  const _PluginHostCallResponse.failure({required this.callId, required this.error})
    : result = null;

  @override
  final String callId;

  @override
  final Object? result;

  @override
  final PluginError? error;

  @override
  bool get isSuccess => error == null;
}
