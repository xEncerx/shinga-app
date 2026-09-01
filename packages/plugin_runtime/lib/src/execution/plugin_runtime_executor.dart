import 'dart:async';
import 'dart:isolate';

import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/src/api/plugin_api_registry.dart';
import 'package:plugin_runtime/src/execution/plugin_invocation.dart';
import 'package:plugin_runtime/src/execution/plugin_runtime_adapter.dart';
import 'package:plugin_runtime/src/execution/plugin_runtime_adapter_registry.dart';
import 'package:plugin_runtime/src/execution/plugin_worker.dart';

typedef _WorkerSpawner = Future<Isolate> Function(Future<Isolate> Function() spawn);
typedef _WorkerMessageSpawner =
    Future<Isolate> Function(
      Map<String, Object?> message,
      Future<Isolate> Function() spawn,
    );

const _workerSpawnerZoneKey = #pluginRuntimeWorkerSpawner;
const _workerDeadlineZoneKey = #pluginRuntimeWorkerDeadlineEpochMicroseconds;
const _wireProtocolV1Identity = 'dev.shinga.plugin-wire.v1';

Future<Isolate> _spawnWorker(Future<Isolate> Function() spawn) => spawn();

/// Executes inspected artifacts through one shared supervised worker lifecycle.
final class PluginRuntimeExecutor {
  /// Creates an executor with immediate admission and generic host-call routing.
  const PluginRuntimeExecutor({
    required this.apiRegistry,
    required this.wireProtocols,
    required this.adapters,
    required this.admission,
    required this.hostCalls,
  });

  /// Registry used to verify the artifact's public API binding.
  final PluginApiRegistry apiRegistry;

  /// Registry used to resolve the artifact's exact internal transport.
  final PluginWireProtocolRegistry wireProtocols;

  /// Registry used to resolve the adapter identity bound into each artifact.
  final PluginRuntimeAdapterRegistry adapters;

  /// The no-queue concurrency gate checked before worker spawn.
  final PluginAdmissionController admission;

  /// The host-operation handler shared by every registered language adapter.
  final PluginHostCallHandler hostCalls;

  /// Executes [invocation] and completes after bounded terminal cleanup.
  Future<PluginInvocationResponse> invoke(PluginInvocation invocation) async {
    if (invocation.cancellationToken?.isCancelled ?? false) {
      return _cancelledFailure();
    }
    final apiAdapter = apiRegistry.adapterForVersion(invocation.artifact.pluginApiVersion);
    if (apiAdapter == null) {
      return _engineFailure('api.unavailable');
    }
    if (apiAdapter.wireProtocolVersion != invocation.artifact.wireProtocolVersion) {
      return _engineFailure('api.wire_binding_mismatch');
    }
    final registeredWireProtocol = wireProtocols.protocolForVersion(
      invocation.artifact.wireProtocolVersion,
    );
    if (registeredWireProtocol == null) {
      return _engineFailure('wire_protocol.unavailable');
    }
    final workerWireProtocol = _builtInWorkerWireProtocol(registeredWireProtocol);
    if (workerWireProtocol == null) {
      return _engineFailure('wire_protocol.worker_unavailable');
    }
    final adapter = adapters.adapterById(invocation.artifact.adapterId);
    if (adapter == null) {
      return _engineFailure('adapter.unavailable');
    }
    final lease = admission.tryAcquire();
    if (lease == null) {
      return workerWireProtocol.protocol.createInvocationFailure(
        PluginError(category: PluginErrorCategory.hostDenied, code: 'admission.saturated'),
      );
    }
    try {
      return await _InvocationSupervisor(
        invocation,
        workerWireProtocol.protocol,
        workerWireProtocol.identity,
        adapter,
        hostCalls,
      ).run();
    } finally {
      lease.release();
    }
  }
}

final class _InvocationSupervisor {
  _InvocationSupervisor(
    this.invocation,
    this.wireProtocol,
    this.wireProtocolIdentity,
    this.adapter,
    this.hostCalls,
  );

  final PluginInvocation invocation;
  final PluginWireProtocol wireProtocol;
  final String wireProtocolIdentity;
  final PluginRuntimeAdapter adapter;
  final PluginHostCallHandler hostCalls;
  final Completer<PluginInvocationResponse> _terminal = Completer();
  final ReceivePort _messages = ReceivePort();
  final ReceivePort _errors = ReceivePort();
  final ReceivePort _workerExits = ReceivePort();
  final Completer<void> _workerExited = Completer();
  final Map<String, _PendingHostCall> _hostOperations = {};
  final List<PluginHostOperation> _cleanupOperations = [];

  Isolate? _worker;
  SendPort? _workerPort;
  StreamSubscription<Object?>? _messageSubscription;
  StreamSubscription<Object?>? _errorSubscription;
  StreamSubscription<Object?>? _workerExitSubscription;
  PluginCancellationRegistration? _cancellationRegistration;
  _PendingWorkerSpawn? _pendingWorkerSpawn;
  Timer? _hardTimer;
  var _hostCallCount = 0;
  var _finishing = false;
  late final DateTime _deadline;
  late final int _deadlineEpochMilliseconds;
  late final int _deadlineEpochMicroseconds;

  Future<PluginInvocationResponse> run() {
    _deadline = DateTime.now().add(invocation.limits.hardDeadline);
    _deadlineEpochMilliseconds = _deadline.millisecondsSinceEpoch;
    _deadlineEpochMicroseconds = _deadline.microsecondsSinceEpoch;
    _messageSubscription = _messages.listen(_handleMessage);
    _errorSubscription = _errors.listen((_) => _claimTerminal(_engineFailure('worker.failure')));
    _workerExitSubscription = _workerExits.listen((_) {
      if (!_workerExited.isCompleted) _workerExited.complete();
    });
    final cancellationRegistration = invocation.cancellationToken?.register(() {
      _claimTerminal(_cancelledFailure());
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

    final Object? adapterPayload;
    final Map<String, Object?> startMessage;
    try {
      adapterPayload = adapter.createWorkerPayload(invocation.artifact);
      startMessage = _workerStartMessage(adapterPayload);
    } on Object {
      _claimTerminal(_engineFailure('adapter.payload_invalid'));
      return _terminal.future;
    }
    final pendingSpawn = _PendingWorkerSpawn(
      this,
      _WorkerSpawnRequest(
        message: startMessage,
        errorPort: _errors.sendPort,
        exitPort: _messages.sendPort,
      ),
      _workerExits.sendPort,
    );
    _pendingWorkerSpawn = pendingSpawn;
    try {
      final zoneSpawner = Zone.current[_workerSpawnerZoneKey];
      final Future<Isolate> spawnFuture;
      if (zoneSpawner is _WorkerMessageSpawner) {
        spawnFuture = zoneSpawner(startMessage, pendingSpawn.spawn);
      } else {
        final spawner = zoneSpawner is _WorkerSpawner ? zoneSpawner : _spawnWorker;
        spawnFuture = spawner(pendingSpawn.spawn);
      }
      unawaited(spawnFuture.then<void>(pendingSpawn.complete, onError: pendingSpawn.reject));
    } on Object {
      _claimTerminal(_engineFailure('worker.failure'));
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
    _claimTerminal(
      _deadlineExpired ? _timeoutFailure() : _engineFailure('worker.failure'),
    );
  }

  Map<String, Object?> _workerStartMessage(Object? adapterPayload) {
    final deadlineOverride = Zone.current[_workerDeadlineZoneKey];
    return <String, Object?>{
      'supervisorPort': _messages.sendPort,
      'workerEntrypoint': adapter.workerEntrypoint,
      'wireProtocolIdentity': wireProtocolIdentity,
      'wireProtocolVersion': wireProtocol.version,
      'adapterPayload': adapterPayload,
      'request': wireProtocol.encodeInvocationRequest(invocation.request),
      'deadlineEpochMilliseconds': _deadlineEpochMilliseconds,
      'deadlineEpochMicroseconds': deadlineOverride is int
          ? deadlineOverride
          : _deadlineEpochMicroseconds,
      'maxPendingHostCalls': invocation.limits.maxPendingHostCalls,
      'maxTotalHostCalls': invocation.limits.maxTotalHostCalls,
    };
  }

  void _handleMessage(Object? message) {
    if (_finishing) return;
    if (_deadlineExpired) {
      _claimTerminal(_timeoutFailure());
      return;
    }
    if (message is! Map<Object?, Object?>) {
      _claimTerminal(_engineFailure('worker.message_invalid'));
      return;
    }
    switch (message['type']) {
      case 'ready':
        final port = message['port'];
        if (port is! SendPort || _workerPort != null) {
          _claimTerminal(_engineFailure('worker.message_invalid'));
          return;
        }
        _workerPort = port;
        return;
      case 'hostCall':
        _handleHostCall(message['request']);
        return;
      case 'terminal':
        try {
          final response = wireProtocol.decodeInvocationResponse(message['response']);
          _claimTerminal(response);
        } on PluginProtocolException {
          _claimTerminal(_protocolFailure('worker.terminal_invalid'));
        }
        return;
      default:
        _claimTerminal(_engineFailure('worker.message_invalid'));
    }
  }

  void _handleHostCall(Object? value) {
    final PluginHostCallRequest request;
    try {
      request = wireProtocol.decodeHostCallRequest(value);
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
        wireProtocol.createHostCallFailure(
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
      _sendHostResponse(request.callId, _hostRejected(request.callId));
      return;
    }
    if (_finishing) {
      _cleanupOperations.add(operation);
      return;
    }
    final pending = _PendingHostCall(this, request.callId, operation);
    _hostOperations[request.callId] = pending;
    pending.listen();
  }

  void _settleHostCall(_PendingHostCall pending, PluginHostCallResponse response) {
    if (_finishing || !identical(_hostOperations.remove(pending.callId), pending)) {
      pending.detach();
      return;
    }
    pending.detach();
    _sendHostResponse(
      pending.callId,
      response.callId == pending.callId
          ? response
          : wireProtocol.createHostCallFailure(
              callId: pending.callId,
              error: PluginError(
                category: PluginErrorCategory.protocolViolation,
                code: 'host_call.response_scope_invalid',
              ),
            ),
    );
  }

  void _sendHostResponse(String callId, PluginHostCallResponse response) {
    if (_finishing) return;
    if (response.callId != callId) {
      _claimTerminal(_protocolFailure('host_call.response_scope_invalid'));
      return;
    }
    try {
      _workerPort?.send(<String, Object?>{
        'type': 'hostResponse',
        'response': wireProtocol.encodeHostCallResponse(response),
      });
    } on PluginProtocolException {
      _claimTerminal(_protocolFailure('host_call.response_invalid'));
    }
  }

  void _claimTerminal(PluginInvocationResponse response) {
    if (_finishing) return;
    _finishing = true;
    _hardTimer?.cancel();
    _cancellationRegistration?.unregister();
    final pendingWorkerSpawn = _pendingWorkerSpawn;
    final waitForWorkerExit = _worker != null || pendingWorkerSpawn?.workerMayExist == true;
    pendingWorkerSpawn?.detach();
    _pendingWorkerSpawn = null;
    _worker?.kill(priority: Isolate.immediate);
    for (final pending in _hostOperations.values) {
      final operation = pending.detach();
      if (operation != null) _cleanupOperations.add(operation);
    }
    _hostOperations.clear();
    unawaited(
      Future<void>.microtask(
        () => _finish(response, waitForWorkerExit: waitForWorkerExit),
      ),
    );
  }

  Future<void> _finish(
    PluginInvocationResponse response, {
    required bool waitForWorkerExit,
  }) async {
    await Future.wait([
      ..._cleanupOperations.map(_cancelHostOperation),
      if (waitForWorkerExit) _awaitWorkerExit(),
    ]);
    await _messageSubscription?.cancel();
    await _errorSubscription?.cancel();
    await _workerExitSubscription?.cancel();
    _messages.close();
    _errors.close();
    _workerExits.close();
    if (!_terminal.isCompleted) _terminal.complete(response);
  }

  Future<void> _awaitWorkerExit() async {
    try {
      await _workerExited.future.timeout(PluginRuntimeLimits.terminalCleanupTimeout);
    } on Object {
      return;
    }
  }

  bool get _deadlineExpired => !DateTime.now().isBefore(_deadline);
}

Future<void> _cancelHostOperation(PluginHostOperation operation) async {
  try {
    await operation.cancel().timeout(PluginRuntimeLimits.terminalCleanupTimeout);
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

  void _complete(PluginHostCallResponse response) {
    _owner?.target?._settleHostCall(this, response);
  }

  void _reject(Object error, StackTrace stackTrace) {
    _complete(_hostRejected(callId));
  }
}

final class _PendingWorkerSpawn {
  _PendingWorkerSpawn(
    _InvocationSupervisor owner,
    this._request,
    this._exitPort,
  ) : _owner = WeakReference(owner);

  WeakReference<_InvocationSupervisor>? _owner;
  _WorkerSpawnRequest? _request;
  final SendPort _exitPort;
  Isolate? _actualWorker;
  var _actualSpawnStarted = false;
  var _actualSpawnFailed = false;

  bool get workerMayExist => _actualSpawnStarted && !_actualSpawnFailed;

  Future<Isolate> spawn() {
    final request = _request;
    if (request == null) return Future<Isolate>.error(StateError('Spawn was cancelled.'));
    _actualSpawnStarted = true;
    final spawn = request.spawn();
    unawaited(spawn.then<void>(_actualSpawned, onError: _actualSpawnRejected));
    return spawn;
  }

  void complete(Isolate worker) {
    if (identical(_actualWorker, worker)) {
      _actualWorker = null;
      return;
    }
    _report(worker);
  }

  void _actualSpawned(Isolate worker) {
    _actualWorker = worker;
    _report(worker);
  }

  void _report(Isolate worker) {
    worker.addOnExitListener(_exitPort);
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

  void _actualSpawnRejected(Object error, StackTrace stackTrace) {
    _actualSpawnFailed = true;
    reject(error, stackTrace);
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
      _runPluginRuntimeWorker,
      message,
      onError: errorPort,
      onExit: exitPort,
    );
  }

  void detach() {
    _message = null;
  }
}

Future<void> _runPluginRuntimeWorker(Map<String, Object?> start) async {
  final supervisorPort = start['supervisorPort']! as SendPort;
  final wireProtocol = _resolveBuiltInWorkerWireProtocol(
    start['wireProtocolIdentity'],
    start['wireProtocolVersion'],
  );
  if (wireProtocol == null) {
    throw const PluginProtocolException('worker.wire_protocol_unavailable');
  }
  final channel = _WorkerHostCallChannel(
    supervisorPort: supervisorPort,
    wireProtocol: wireProtocol,
    request: wireProtocol.decodeInvocationRequest(start['request']),
    deadlineEpochMilliseconds: start['deadlineEpochMilliseconds']! as int,
    maxPendingHostCalls: start['maxPendingHostCalls']! as int,
    maxTotalHostCalls: start['maxTotalHostCalls']! as int,
  );
  supervisorPort.send(<String, Object?>{'type': 'ready', 'port': channel.sendPort});

  PluginInvocationResponse response;
  try {
    final entrypoint = start['workerEntrypoint']! as PluginWorkerEntrypoint;
    final context = PluginWorkerContext(
      request: channel.request,
      deadlineEpochMilliseconds: channel.deadlineEpochMilliseconds,
      deadlineEpochMicroseconds: start['deadlineEpochMicroseconds']! as int,
      hostCalls: channel,
    );
    response = await Future.any([
      Future<PluginInvocationResponse>.sync(
        () => entrypoint(context, start['adapterPayload']),
      ),
      channel.protocolFailure,
    ]);
  } on PluginProtocolException {
    response = _protocolFailure('worker.adapter_value_invalid');
  } on Object {
    response = _engineFailure('worker.adapter_failure');
  }
  Map<String, Object?> encodedResponse;
  try {
    encodedResponse = wireProtocol.encodeInvocationResponse(response);
  } on PluginProtocolException {
    encodedResponse = wireProtocol.encodeInvocationResponse(
      _protocolFailure('worker.adapter_value_invalid'),
    );
  }
  await channel.close();
  Isolate.exit(supervisorPort, <String, Object?>{
    'type': 'terminal',
    'response': encodedResponse,
  });
}

({String identity, PluginWireProtocol protocol})? _builtInWorkerWireProtocol(
  PluginWireProtocol registeredProtocol,
) {
  return switch (registeredProtocol) {
    PluginWireProtocolV1() => (
      identity: _wireProtocolV1Identity,
      protocol: const PluginWireProtocolV1(),
    ),
    _ => null,
  };
}

PluginWireProtocol? _resolveBuiltInWorkerWireProtocol(Object? identity, Object? version) {
  return switch ((identity, version)) {
    (_wireProtocolV1Identity, PluginWireProtocolV1.wireVersion) => const PluginWireProtocolV1(),
    _ => null,
  };
}

final class _WorkerHostCallChannel implements PluginWorkerHostCalls {
  _WorkerHostCallChannel({
    required this.supervisorPort,
    required this.wireProtocol,
    required this.request,
    required this.deadlineEpochMilliseconds,
    required this.maxPendingHostCalls,
    required this.maxTotalHostCalls,
  }) {
    _subscription = _commands.listen(_handleResponse);
  }

  final SendPort supervisorPort;
  final PluginWireProtocol wireProtocol;
  final PluginInvocationRequest request;
  final int deadlineEpochMilliseconds;
  final int maxPendingHostCalls;
  final int maxTotalHostCalls;
  final ReceivePort _commands = ReceivePort();
  final Map<String, Completer<PluginHostCallResponse>> _pending = {};
  final Completer<PluginInvocationResponse> _protocolFailure = Completer();
  late final StreamSubscription<Object?> _subscription;
  var _totalHostCalls = 0;
  var _closed = false;

  SendPort get sendPort => _commands.sendPort;

  Future<PluginInvocationResponse> get protocolFailure => _protocolFailure.future;

  @override
  Future<PluginHostCallResponse> call(String operation, Object? payload) {
    _totalHostCalls += 1;
    final callId = 'call-$_totalHostCalls';
    if (_closed || _totalHostCalls > maxTotalHostCalls || _pending.length >= maxPendingHostCalls) {
      return Future.value(_hostLimitFailure(callId));
    }
    final PluginHostCallRequest hostRequest;
    try {
      hostRequest = wireProtocol.createHostCallRequest(
        invocationId: request.invocationId,
        callId: callId,
        pluginId: request.pluginId,
        pluginApiVersion: request.pluginApiVersion,
        operation: operation,
        deadlineEpochMilliseconds: deadlineEpochMilliseconds,
        payload: payload,
      );
    } on PluginProtocolException {
      return Future.value(
        wireProtocol.createHostCallFailure(
          callId: callId,
          error: PluginError(
            category: PluginErrorCategory.protocolViolation,
            code: 'host_call.payload_invalid',
          ),
        ),
      );
    }
    final completer = Completer<PluginHostCallResponse>();
    _pending[callId] = completer;
    supervisorPort.send(<String, Object?>{
      'type': 'hostCall',
      'request': wireProtocol.encodeHostCallRequest(hostRequest),
    });
    return completer.future.whenComplete(() => _pending.remove(callId));
  }

  void _handleResponse(Object? message) {
    if (_closed) return;
    if (message is! Map<Object?, Object?> || message['type'] != 'hostResponse') {
      _failProtocol('worker.host_response_invalid');
      return;
    }
    final PluginHostCallResponse response;
    try {
      response = wireProtocol.decodeHostCallResponse(message['response']);
    } on PluginProtocolException {
      _failProtocol('worker.host_response_invalid');
      return;
    }
    final completer = _pending.remove(response.callId);
    if (completer == null || completer.isCompleted) {
      _failProtocol('worker.host_response_scope_invalid');
      return;
    }
    completer.complete(response);
  }

  @override
  Map<String, Object?> encodeResponse(PluginHostCallResponse response) {
    return wireProtocol.encodeHostCallResponse(response);
  }

  void _failProtocol(String code) {
    if (_protocolFailure.isCompleted) return;
    _protocolFailure.complete(_protocolFailureResponse(code));
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    for (final entry in _pending.entries) {
      if (!entry.value.isCompleted) {
        entry.value.complete(
          wireProtocol.createHostCallFailure(
            callId: entry.key,
            error: PluginError(
              category: PluginErrorCategory.cancelled,
              code: 'host_call.cancelled',
            ),
          ),
        );
      }
    }
    _pending.clear();
    await _subscription.cancel();
    _commands.close();
  }
}

PluginInvocationResponse _cancelledFailure() {
  return PluginInvocationResponse.failure(
    PluginError(category: PluginErrorCategory.cancelled, code: 'invocation.cancelled'),
  );
}

PluginInvocationResponse _timeoutFailure() {
  return PluginInvocationResponse.failure(
    PluginError(category: PluginErrorCategory.timeout, code: 'invocation.hard_timeout'),
  );
}

PluginInvocationResponse _engineFailure(String code) {
  return PluginInvocationResponse.failure(
    PluginError(category: PluginErrorCategory.engineFailure, code: code),
  );
}

PluginInvocationResponse _protocolFailure(String code) {
  return PluginInvocationResponse.failure(
    PluginError(category: PluginErrorCategory.protocolViolation, code: code),
  );
}

PluginInvocationResponse _protocolFailureResponse(String code) => _protocolFailure(code);

PluginHostCallResponse _hostRejected(String callId) {
  return PluginHostCallResponse.failure(
    callId: callId,
    error: PluginError(
      category: PluginErrorCategory.hostDenied,
      code: 'host_call.rejected',
    ),
  );
}

PluginHostCallResponse _hostLimitFailure(String callId) {
  return PluginHostCallResponse.failure(
    callId: callId,
    error: PluginError(
      category: PluginErrorCategory.hostDenied,
      code: 'host_call.limit_exceeded',
    ),
  );
}
