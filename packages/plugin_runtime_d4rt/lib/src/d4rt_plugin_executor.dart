import 'dart:async';
import 'dart:isolate';

import 'package:d4rt/d4rt.dart';
import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/plugin_runtime.dart';

typedef _WorkerSpawner = Future<Isolate> Function(Future<Isolate> Function() spawn);

const _workerSpawnerZoneKey = #pluginRuntimeD4rtWorkerSpawner;
const _workerExecutionObserverZoneKey = #pluginRuntimeD4rtExecutionObserver;
const _workerDeadlineZoneKey = #pluginRuntimeD4rtWorkerDeadlineEpochMicroseconds;

Future<Isolate> _spawnWorker(Future<Isolate> Function() spawn) => spawn();

/// Executes one inspected method in one fresh bounded worker isolate and D4rt.
final class D4rtPluginExecutor {
  /// Creates an executor with immediate bounded [admission] and one generic [hostCalls] transport.
  const D4rtPluginExecutor({required this.admission, required this.hostCalls});

  /// The no-queue concurrency gate checked before worker spawn.
  final PluginAdmissionController admission;

  /// The generic child-operation handler used for every invocation.
  final PluginHostCallHandler hostCalls;

  /// Executes [invocation] and returns exactly one bounded terminal envelope.
  Future<PluginInvocationResponseV1> invoke(PluginInvocation invocation) async {
    if (invocation.cancellationToken?.isCancelled ?? false) {
      return PluginInvocationResponseV1.failure(
        PluginError(category: PluginErrorCategory.cancelled, code: 'invocation.cancelled'),
      );
    }
    final lease = admission.tryAcquire();
    if (lease == null) {
      return PluginInvocationResponseV1.failure(
        PluginError(category: PluginErrorCategory.hostDenied, code: 'admission.saturated'),
      );
    }
    try {
      return await _InvocationSupervisor(invocation, hostCalls).run();
    } finally {
      lease.release();
    }
  }
}

final class _InvocationSupervisor {
  _InvocationSupervisor(this.invocation, this.hostCalls);

  final PluginInvocation invocation;
  final PluginHostCallHandler hostCalls;
  final Completer<PluginInvocationResponseV1> _terminal = Completer();
  final ReceivePort _messages = ReceivePort();
  final ReceivePort _errors = ReceivePort();
  final Map<String, _PendingHostCall> _hostOperations = {};

  Isolate? _worker;
  SendPort? _workerPort;
  StreamSubscription<Object?>? _messageSubscription;
  StreamSubscription<Object?>? _errorSubscription;
  PluginCancellationRegistration? _cancellationRegistration;
  _PendingWorkerSpawn? _pendingWorkerSpawn;
  Timer? _hardTimer;
  var _hostCallCount = 0;
  var _finishing = false;
  late final DateTime _deadline;
  late final int _deadlineEpochMilliseconds;
  late final int _deadlineEpochMicroseconds;

  Future<PluginInvocationResponseV1> run() {
    _deadline = DateTime.now().add(invocation.limits.hostHardDeadline);
    _deadlineEpochMilliseconds = _deadline.millisecondsSinceEpoch;
    _deadlineEpochMicroseconds = _deadline.microsecondsSinceEpoch;
    _messageSubscription = _messages.listen(_handleMessage);
    _errorSubscription = _errors.listen((_) {
      _claimTerminal(_engineFailure());
    });
    final cancellationRegistration = invocation.cancellationToken?.register(() {
      _claimTerminal(
        PluginInvocationResponseV1.failure(
          PluginError(category: PluginErrorCategory.cancelled, code: 'invocation.cancelled'),
        ),
      );
    });
    _cancellationRegistration = cancellationRegistration;
    if (_finishing) {
      cancellationRegistration?.unregister();
      return _terminal.future;
    }
    final hardDelay = _deadline.difference(DateTime.now());
    _hardTimer = Timer(
      hardDelay.isNegative ? Duration.zero : hardDelay,
      () => _claimTerminal(_timeoutFailure()),
    );
    final pendingSpawn = _PendingWorkerSpawn(
      this,
      _WorkerSpawnRequest(
        message: _workerStartMessage(),
        errorPort: _errors.sendPort,
        exitPort: _messages.sendPort,
      ),
    );
    _pendingWorkerSpawn = pendingSpawn;
    try {
      final zoneSpawner = Zone.current[_workerSpawnerZoneKey];
      final spawner = zoneSpawner is _WorkerSpawner ? zoneSpawner : _spawnWorker;
      final spawnFuture = spawner(pendingSpawn.spawn);
      unawaited(spawnFuture.then<void>(pendingSpawn.complete, onError: pendingSpawn.reject));
    } on Object {
      pendingSpawn.detach();
      _pendingWorkerSpawn = null;
      _claimTerminal(_engineFailure());
    }
    return _terminal.future;
  }

  void _workerSpawned(_PendingWorkerSpawn pending, Isolate worker) {
    if (!identical(_pendingWorkerSpawn, pending)) {
      worker.kill(priority: Isolate.immediate);
      return;
    }
    _pendingWorkerSpawn = null;
    pending.detach();
    if (_finishing || _deadlineExpired) {
      worker.kill(priority: Isolate.immediate);
      if (!_finishing) _claimTerminal(_timeoutFailure());
      return;
    }
    _worker = worker;
  }

  void _workerSpawnFailed(_PendingWorkerSpawn pending) {
    if (!identical(_pendingWorkerSpawn, pending)) return;
    _pendingWorkerSpawn = null;
    pending.detach();
    _claimTerminal(_deadlineExpired ? _timeoutFailure() : _engineFailure());
  }

  Map<String, Object?> _workerStartMessage() {
    final executionObserver = Zone.current[_workerExecutionObserverZoneKey];
    final deadlineOverride = Zone.current[_workerDeadlineZoneKey];
    return <String, Object?>{
      'supervisorPort': _messages.sendPort,
      'entryModuleId': invocation.artifact.entryModuleId,
      'sources': Map<String, String>.of(invocation.artifact.sources),
      'request': invocation.request.toJson(),
      'maxSteps': invocation.limits.maxSteps,
      'timeoutMicroseconds': invocation.limits.timeout.inMicroseconds,
      'deadlineEpochMilliseconds': _deadlineEpochMilliseconds,
      'deadlineEpochMicroseconds': deadlineOverride is int
          ? deadlineOverride
          : _deadlineEpochMicroseconds,
      'maxPendingHostCalls': invocation.limits.maxPendingHostCalls,
      'maxTotalHostCalls': invocation.limits.maxTotalHostCalls,
      if (executionObserver is SendPort) 'executionObserver': executionObserver,
    };
  }

  void _handleMessage(Object? message) {
    if (_finishing) return;
    if (_deadlineExpired) {
      _claimTerminal(_timeoutFailure());
      return;
    }
    if (message == null) {
      _claimTerminal(_engineFailure());
      return;
    }
    if (message is! Map<Object?, Object?>) {
      _claimTerminal(_engineFailure());
      return;
    }
    switch (message['type']) {
      case 'ready':
        final port = message['port'];
        if (port is! SendPort) {
          _claimTerminal(_engineFailure());
          return;
        }
        _workerPort = port;
        return;
      case 'hostCall':
        _handleHostCall(message['request']);
        return;
      case 'terminal':
        try {
          final response = PluginWireCodec.decodeInvocationResponse(message['response']);
          _claimTerminal(response);
        } on PluginProtocolException {
          _claimTerminal(_protocolFailure('worker.terminal_invalid'));
        }
        return;
      default:
        _claimTerminal(_engineFailure());
    }
  }

  void _handleHostCall(Object? value) {
    final PluginHostCallRequestV1 request;
    try {
      request = PluginWireCodec.decodeHostCallRequest(value);
    } on PluginProtocolException {
      _claimTerminal(_protocolFailure('host_call.request_invalid'));
      return;
    }
    if (request.invocationId != invocation.request.invocationId ||
        request.pluginId != invocation.request.pluginId ||
        request.pluginApiVersion != invocation.request.pluginApiVersion ||
        request.deadlineEpochMilliseconds != _deadlineEpochMilliseconds ||
        _hostOperations.containsKey(request.callId)) {
      _claimTerminal(_protocolFailure('host_call.scope_invalid'));
      return;
    }
    _hostCallCount += 1;
    if (_hostCallCount > invocation.limits.maxTotalHostCalls ||
        _hostOperations.length >= invocation.limits.maxPendingHostCalls) {
      _sendHostResponse(
        request.callId,
        PluginHostCallResponseV1.failure(
          callId: request.callId,
          error: PluginError(
            category: PluginErrorCategory.hostDenied,
            code: 'host_call.limit_exceeded',
          ),
        ),
      );
      return;
    }

    final PluginHostOperation operation;
    try {
      operation = hostCalls.start(request);
    } on Object {
      _sendHostResponse(
        request.callId,
        PluginHostCallResponseV1.failure(
          callId: request.callId,
          error: PluginError(
            category: PluginErrorCategory.hostDenied,
            code: 'host_call.rejected',
          ),
        ),
      );
      return;
    }
    if (_finishing) {
      unawaited(_cancelHostOperation(operation));
      return;
    }
    final pending = _PendingHostCall(this, request.callId, operation);
    _hostOperations[request.callId] = pending;
    pending.listen();
  }

  void _settleHostCall(_PendingHostCall pending, PluginHostCallResponseV1 response) {
    if (_finishing || !identical(_hostOperations.remove(pending.callId), pending)) {
      pending.detach();
      return;
    }
    pending.detach();
    _sendHostResponse(
      pending.callId,
      response.callId == pending.callId
          ? response
          : PluginHostCallResponseV1.failure(
              callId: pending.callId,
              error: PluginError(
                category: PluginErrorCategory.protocolViolation,
                code: 'host_call.response_scope_invalid',
              ),
            ),
    );
  }

  void _sendHostResponse(String callId, PluginHostCallResponseV1 response) {
    if (_finishing) return;
    if (response.callId != callId) {
      _claimTerminal(_protocolFailure('host_call.response_scope_invalid'));
      return;
    }
    _workerPort?.send(<String, Object?>{
      'type': 'hostResponse',
      'response': response.toJson(),
    });
  }

  void _claimTerminal(PluginInvocationResponseV1 response) {
    if (_finishing) return;
    _finishing = true;
    _hardTimer?.cancel();
    _cancellationRegistration?.unregister();
    _pendingWorkerSpawn?.detach();
    _pendingWorkerSpawn = null;
    _worker?.kill(priority: Isolate.immediate);
    final operations = _hostOperations.values
        .map((pending) => pending.detach())
        .nonNulls
        .toList(growable: false);
    _hostOperations.clear();
    if (!_terminal.isCompleted) _terminal.complete(response);
    unawaited(_cleanup(operations));
  }

  Future<void> _cleanup(List<PluginHostOperation> operations) async {
    await Future.wait(
      operations.map(
        _cancelHostOperation,
      ),
    );
    await _messageSubscription?.cancel();
    await _errorSubscription?.cancel();
    _messages.close();
    _errors.close();
  }

  PluginInvocationResponseV1 _engineFailure() {
    return PluginInvocationResponseV1.failure(
      PluginError(category: PluginErrorCategory.engineFailure, code: 'worker.failure'),
    );
  }

  bool get _deadlineExpired => !DateTime.now().isBefore(_deadline);

  PluginInvocationResponseV1 _timeoutFailure() {
    return PluginInvocationResponseV1.failure(
      PluginError(category: PluginErrorCategory.timeout, code: 'invocation.hard_timeout'),
    );
  }

  PluginInvocationResponseV1 _protocolFailure(String code) {
    return PluginInvocationResponseV1.failure(
      PluginError(category: PluginErrorCategory.protocolViolation, code: code),
    );
  }
}

Future<void> _cancelHostOperation(PluginHostOperation operation) async {
  try {
    await operation.cancel().timeout(const Duration(milliseconds: 100));
  } on Object {
    return;
  }
}

final class _PendingHostCall {
  _PendingHostCall(
    _InvocationSupervisor owner,
    this.callId,
    PluginHostOperation operation,
  ) : _owner = WeakReference(owner),
      _operation = operation;

  final String callId;
  WeakReference<_InvocationSupervisor>? _owner;
  PluginHostOperation? _operation;

  void listen() {
    unawaited(_operation!.response.then<void>(_complete, onError: _reject));
  }

  PluginHostOperation? detach() {
    _owner = null;
    final operation = _operation;
    _operation = null;
    return operation;
  }

  void _complete(PluginHostCallResponseV1 response) {
    _owner?.target?._settleHostCall(this, response);
  }

  void _reject(Object error, StackTrace stackTrace) {
    _complete(
      PluginHostCallResponseV1.failure(
        callId: callId,
        error: PluginError(
          category: PluginErrorCategory.hostDenied,
          code: 'host_call.rejected',
        ),
      ),
    );
  }
}

final class _PendingWorkerSpawn {
  _PendingWorkerSpawn(_InvocationSupervisor owner, this._request) : _owner = WeakReference(owner);

  WeakReference<_InvocationSupervisor>? _owner;
  _WorkerSpawnRequest? _request;

  Future<Isolate> spawn() {
    final request = _request;
    if (request == null) return Future<Isolate>.error(StateError('Spawn was cancelled.'));
    return request.spawn();
  }

  void complete(Isolate worker) {
    final owner = _owner?.target;
    if (owner == null) {
      worker.kill(priority: Isolate.immediate);
      return;
    }
    owner._workerSpawned(this, worker);
  }

  void reject(Object error, StackTrace stackTrace) {
    _owner?.target?._workerSpawnFailed(this);
  }

  void detach() {
    _owner = null;
    _request?.detach();
    _request = null;
  }
}

final class _WorkerSpawnRequest {
  _WorkerSpawnRequest({
    required Map<String, Object?> message,
    required this.errorPort,
    required this.exitPort,
  }) : _message = message;

  Map<String, Object?>? _message;
  final SendPort errorPort;
  final SendPort exitPort;

  Future<Isolate> spawn() {
    final message = _message;
    if (message == null) return Future<Isolate>.error(StateError('Spawn was cancelled.'));
    _message = null;
    return Isolate.spawn<Map<String, Object?>>(
      _runD4rtWorker,
      message,
      onError: errorPort,
      onExit: exitPort,
    );
  }

  void detach() {
    _message = null;
  }
}

Future<void> _runD4rtWorker(Map<String, Object?> start) async {
  final supervisorPort = start['supervisorPort']! as SendPort;
  final commandPort = ReceivePort();
  final pendingCalls = <String, Completer<Map<String, Object?>>>{};
  var totalHostCalls = 0;
  supervisorPort.send(<String, Object?>{'type': 'ready', 'port': commandPort.sendPort});
  final commandSubscription = commandPort.listen((message) {
    if (message is! Map<Object?, Object?> || message['type'] != 'hostResponse') return;
    try {
      final response = PluginWireCodec.decodeHostCallResponse(message['response']);
      final completer = pendingCalls.remove(response.callId);
      if (completer == null || completer.isCompleted) return;
      completer.complete(response.toJson());
    } on PluginProtocolException {
      return;
    }
  });

  PluginInvocationResponseV1 response;
  try {
    final request = PluginWireCodec.decodeInvocationRequest(start['request']);
    final maxPendingHostCalls = start['maxPendingHostCalls']! as int;
    final maxTotalHostCalls = start['maxTotalHostCalls']! as int;
    final deadlineEpochMilliseconds = start['deadlineEpochMilliseconds']! as int;
    final d4rt = D4rt()
      ..registertopLevelFunction(
        '__shingaHostCall',
        (visitor, positionalArgs, namedArgs, typeArgs) {
          final operation = positionalArgs.firstOrNull;
          if (positionalArgs.length != 2 || operation is! String) {
            return Future<Map<String, Object?>>.value(
              PluginHostCallResponseV1.failure(
                callId: 'call-invalid',
                error: PluginError(
                  category: PluginErrorCategory.protocolViolation,
                  code: 'host_call.arguments_invalid',
                ),
              ).toJson(),
            );
          }
          totalHostCalls += 1;
          if (totalHostCalls > maxTotalHostCalls || pendingCalls.length >= maxPendingHostCalls) {
            final callId = 'call-$totalHostCalls';
            return Future<Map<String, Object?>>.value(
              PluginHostCallResponseV1.failure(
                callId: callId,
                error: PluginError(
                  category: PluginErrorCategory.hostDenied,
                  code: 'host_call.limit_exceeded',
                ),
              ).toJson(),
            );
          }
          final callId = 'call-$totalHostCalls';
          final PluginHostCallRequestV1 hostRequest;
          try {
            hostRequest = PluginHostCallRequestV1(
              invocationId: request.invocationId,
              callId: callId,
              pluginId: request.pluginId,
              pluginApiVersion: request.pluginApiVersion,
              operation: operation,
              deadlineEpochMilliseconds: deadlineEpochMilliseconds,
              payload: positionalArgs[1],
            );
          } on PluginProtocolException {
            return Future<Map<String, Object?>>.value(
              PluginHostCallResponseV1.failure(
                callId: callId,
                error: PluginError(
                  category: PluginErrorCategory.protocolViolation,
                  code: 'host_call.payload_invalid',
                ),
              ).toJson(),
            );
          }
          final completer = Completer<Map<String, Object?>>();
          pendingCalls[callId] = completer;
          supervisorPort.send(<String, Object?>{
            'type': 'hostCall',
            'request': hostRequest.toJson(),
          });
          return completer.future.whenComplete(() => pendingCalls.remove(callId));
        },
      );
    final sourcesValue = start['sources']! as Map<Object?, Object?>;
    final sources = <String, String>{
      for (final entry in sourcesValue.entries) entry.key! as String: entry.value! as String,
    };
    final configuredTimeoutMicroseconds = start['timeoutMicroseconds']! as int;
    final remainingMicroseconds =
        (start['deadlineEpochMicroseconds']! as int) - DateTime.now().microsecondsSinceEpoch;
    final executionObserver = start['executionObserver'];
    if (remainingMicroseconds <= 0) {
      if (executionObserver is SendPort) {
        executionObserver.send(<String, Object?>{
          'didExecute': false,
          'remainingMicroseconds': remainingMicroseconds,
        });
      }
      response = PluginInvocationResponseV1.failure(
        PluginError(category: PluginErrorCategory.timeout, code: 'invocation.hard_timeout'),
      );
    } else {
      final cooperativeTimeoutMicroseconds = configuredTimeoutMicroseconds < remainingMicroseconds
          ? configuredTimeoutMicroseconds
          : remainingMicroseconds;
      if (executionObserver is SendPort) {
        executionObserver.send(<String, Object?>{
          'didExecute': true,
          'remainingMicroseconds': remainingMicroseconds,
          'cooperativeTimeoutMicroseconds': cooperativeTimeoutMicroseconds,
        });
      }
      final result = await Future<Object?>.value(
        d4rt.execute(
              library: start['entryModuleId']! as String,
              sources: sources,
              name: request.method,
              positionalArgs: [request.params],
              // Keep the security boundary visible even though D4rt defaults to false.
              // ignore: avoid_redundant_argument_values
              allowFileSystemImports: false,
              maxSteps: start['maxSteps']! as int,
              timeout: Duration(microseconds: cooperativeTimeoutMicroseconds),
              onPrint: (_) {},
            )
            as Object?,
      );
      response = PluginInvocationResponseV1.success(result);
    }
  } on ExecutionLimitException {
    response = PluginInvocationResponseV1.failure(
      PluginError(category: PluginErrorCategory.executionLimit, code: 'execution.step_limit'),
    );
  } on ExecutionTimeoutException {
    response = PluginInvocationResponseV1.failure(
      PluginError(category: PluginErrorCategory.timeout, code: 'execution.d4rt_timeout'),
    );
  } on PluginProtocolException {
    response = PluginInvocationResponseV1.failure(
      PluginError(category: PluginErrorCategory.protocolViolation, code: 'execution.value_invalid'),
    );
  } on SourceCodeException {
    response = PluginInvocationResponseV1.failure(
      PluginError(category: PluginErrorCategory.engineFailure, code: 'engine.source_failure'),
    );
  } on RuntimeError {
    response = PluginInvocationResponseV1.failure(
      PluginError(category: PluginErrorCategory.pluginException, code: 'plugin.exception'),
    );
  } on Object {
    response = PluginInvocationResponseV1.failure(
      PluginError(category: PluginErrorCategory.engineFailure, code: 'engine.failure'),
    );
  }
  await commandSubscription.cancel();
  commandPort.close();
  Isolate.exit(supervisorPort, <String, Object?>{
    'type': 'terminal',
    'response': response.toJson(),
  });
}
