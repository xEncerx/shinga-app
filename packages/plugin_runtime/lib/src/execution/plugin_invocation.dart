import 'dart:async';

import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/src/execution/plugin_executable_artifact.dart';

/// Release ceilings enforced by the shared runtime supervisor.
abstract final class PluginRuntimeLimits {
  /// Maximum absolute hard deadline accepted for one invocation.
  static const Duration maxHardDeadline = Duration(seconds: 30);

  /// Maximum configured concurrent invocations.
  static const int maxConcurrency = 16;

  /// Maximum wait for cancellation of one detached host operation.
  static const Duration terminalCleanupTimeout = Duration(milliseconds: 100);
}

/// Validated language-independent limits for one invocation.
final class PluginInvocationLimits {
  /// Creates positive limits that cannot exceed release hard ceilings.
  factory PluginInvocationLimits({
    required Duration hardDeadline,
    int maxPendingHostCalls = PluginProtocolLimits.maxPendingHostCalls,
    int maxTotalHostCalls = PluginProtocolLimits.maxTotalHostCalls,
  }) {
    if (hardDeadline <= Duration.zero || hardDeadline > PluginRuntimeLimits.maxHardDeadline) {
      throw ArgumentError.value(
        hardDeadline,
        'hardDeadline',
        'must be within 1 microsecond and 30 seconds',
      );
    }
    if (maxPendingHostCalls <= 0 ||
        maxPendingHostCalls > PluginProtocolLimits.maxPendingHostCalls ||
        maxTotalHostCalls <= 0 ||
        maxTotalHostCalls > PluginProtocolLimits.maxTotalHostCalls ||
        maxPendingHostCalls > maxTotalHostCalls) {
      throw ArgumentError('Host-call limits must be positive and within protocol ceilings.');
    }
    return PluginInvocationLimits._(
      hardDeadline: hardDeadline,
      maxPendingHostCalls: maxPendingHostCalls,
      maxTotalHostCalls: maxTotalHostCalls,
    );
  }

  PluginInvocationLimits._({
    required this.hardDeadline,
    required this.maxPendingHostCalls,
    required this.maxTotalHostCalls,
  });

  /// Absolute supervisor duration after which the worker is killed.
  final Duration hardDeadline;

  /// Maximum simultaneously pending child calls, inclusive.
  final int maxPendingHostCalls;

  /// Maximum child calls created during the invocation, inclusive.
  final int maxTotalHostCalls;
}

/// A complete immutable request to execute one inspected method.
final class PluginInvocation {
  /// Creates an invocation and verifies the request matches [artifact].
  PluginInvocation({
    required this.artifact,
    required this.request,
    required this.limits,
    this.cancellationToken,
  }) {
    if (request.pluginId != artifact.pluginId ||
        request.pluginVersion != artifact.pluginVersion ||
        request.pluginApiVersion != artifact.pluginApiVersion) {
      throw const PluginProtocolException('invocation.artifact_identity_mismatch');
    }
  }

  /// The exact immutable sources approved by inspection.
  final PluginExecutableArtifact artifact;

  /// The versioned bounded method request.
  final PluginInvocationRequest request;

  /// Mandatory positive execution and child-call limits.
  final PluginInvocationLimits limits;

  /// Optional caller-owned cancellation scope.
  final PluginCancellationToken? cancellationToken;
}

/// A read-only cooperative cancellation signal for an invocation.
final class PluginCancellationToken {
  PluginCancellationToken._(this._completer);

  final Completer<void> _completer;
  final Set<void Function()> _listeners = {};

  /// Whether cancellation has already been requested.
  bool get isCancelled => _completer.isCompleted;

  /// Completes once when cancellation is requested.
  Future<void> get whenCancelled => _completer.future;

  /// Registers a callback that synchronously observes the cancellation claim.
  ///
  /// The callback runs before [PluginCancellationController.cancel] returns so
  /// terminal ownership cannot be overtaken by an already-queued completion.
  /// Every current listener runs in registration order; after notification the
  /// first listener error is rethrown with its original stack trace.
  PluginCancellationRegistration register(void Function() listener) {
    if (isCancelled) {
      listener();
      return PluginCancellationRegistration._(null, null);
    }
    _listeners.add(listener);
    return PluginCancellationRegistration._(this, listener);
  }

  void _notifyListeners() {
    final listeners = _listeners.toList(growable: false);
    _listeners.clear();
    Object? firstError;
    StackTrace? firstStackTrace;
    for (final listener in listeners) {
      try {
        listener();
      } on Object catch (error, stackTrace) {
        firstError ??= error;
        firstStackTrace ??= stackTrace;
      }
    }
    if (firstError != null) {
      Error.throwWithStackTrace(firstError, firstStackTrace!);
    }
  }

  void _removeListener(void Function() listener) {
    _listeners.remove(listener);
  }
}

/// Detaches one synchronous cancellation callback from its token.
final class PluginCancellationRegistration {
  PluginCancellationRegistration._(this._token, this._listener);

  PluginCancellationToken? _token;
  void Function()? _listener;

  /// Stops future notification and releases callback-owned resources.
  void unregister() {
    final listener = _listener;
    if (listener == null) return;
    _token?._removeListener(listener);
    _token = null;
    _listener = null;
  }
}

/// Owns a cancellation token and can cancel it exactly once.
final class PluginCancellationController {
  /// Creates an uncancelled scope.
  PluginCancellationController() : _completer = Completer<void>() {
    token = PluginCancellationToken._(_completer);
  }

  final Completer<void> _completer;

  /// The read-only signal passed to an invocation.
  late final PluginCancellationToken token;

  /// Requests cancellation and ignores repeated requests.
  ///
  /// All listeners are notified synchronously even when one throws. The first
  /// listener error is rethrown only after every listener has observed cancel.
  void cancel() {
    if (_completer.isCompleted) return;
    _completer.complete();
    token._notifyListeners();
  }
}

/// Cancels a pending host operation when its parent terminates.
typedef PluginHostOperationCancel = FutureOr<void> Function();

/// One bounded host operation and its optional cancellation handle.
final class PluginHostOperation {
  /// Creates an operation from its eventual structured [response].
  PluginHostOperation({required this.response, PluginHostOperationCancel? onCancel})
    : _onCancel = onCancel;

  /// Creates an already-settled host operation.
  PluginHostOperation.completed(PluginHostCallResponse response)
    : response = Future.value(response),
      _onCancel = null;

  /// The structured response delivered to plugin code.
  final Future<PluginHostCallResponse> response;

  PluginHostOperationCancel? _onCancel;

  /// Requests cancellation when the operation provides a handle.
  Future<void> cancel() {
    final onCancel = _onCancel;
    _onCancel = null;
    if (onCancel == null) return Future<void>.value();
    return Future<void>.sync(onCancel);
  }
}

/// Handles one generic versioned host-call transport operation.
abstract interface class PluginHostCallHandler {
  /// Starts [request] immediately without retaining an unbounded queue.
  PluginHostOperation start(PluginHostCallRequest request);
}

/// A fixed-capacity admission controller with immediate denial on saturation.
final class PluginAdmissionController {
  /// Creates admission with no queue and a release hard maximum of 16.
  PluginAdmissionController({required int maxConcurrent}) : maxConcurrent = maxConcurrent {
    if (maxConcurrent <= 0 || maxConcurrent > PluginRuntimeLimits.maxConcurrency) {
      throw ArgumentError.value(maxConcurrent, 'maxConcurrent', 'must be within 1..16');
    }
  }

  /// The configured simultaneous invocation capacity.
  final int maxConcurrent;

  int _active = 0;

  /// The number of currently admitted invocations.
  int get active => _active;

  /// Acquires immediately or returns `null` instead of queueing.
  PluginAdmissionLease? tryAcquire() {
    if (_active >= maxConcurrent) return null;
    _active += 1;
    return PluginAdmissionLease._(this);
  }

  void _release() {
    if (_active > 0) _active -= 1;
  }
}

/// An idempotent admission permit released by every terminal path.
final class PluginAdmissionLease {
  PluginAdmissionLease._(this._owner);

  final PluginAdmissionController _owner;
  bool _released = false;

  /// Releases capacity once and ignores repeated cleanup.
  void release() {
    if (_released) return;
    _released = true;
    _owner._release();
  }
}
