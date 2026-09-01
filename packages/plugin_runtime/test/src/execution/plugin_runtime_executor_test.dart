import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/plugin_runtime.dart';
import 'package:plugin_runtime/plugin_runtime_testing.dart';
import 'package:test/test.dart';

final _artifacts = <String, PluginExecutableArtifact>{};

void main() {
  setUpAll(() async {
    for (final mode in [
      'echo',
      'failure',
      'hostNever',
      'hostSequential',
      'hostConcurrent',
    ]) {
      _artifacts['fixture:$mode'] = await _mintArtifact(mode, 'fixture');
    }
    _artifacts['missing:echo'] = await _mintArtifact('echo', 'missing');
    _artifacts['fixture:apiVersionEcho'] = await _mintArtifact(
      'apiVersionEcho',
      'fixture',
      pluginApiVersion: 2,
    );
  });

  test('executes adapter success and failure in runtime-created workers', () async {
    final executor = _executor(_Host());

    final success = await executor.invoke(_invocation(_artifact('echo'), params: {'value': 1}));
    final failure = await executor.invoke(_invocation(_artifact('failure')));

    expect(success.result, {'value': 1});
    expect(failure.error?.code, 'fixture.failure');
  });

  test('executes coexisting API1 and API2 over wire1 in real workers', () async {
    final wireProtocols = PluginWireProtocolRegistry.builtIn();
    final apiRegistry = PluginApiRegistry(
      adapters: const [PluginApiV1Adapter(), _FixtureApiAdapter(2, 1)],
      wireProtocols: wireProtocols,
    );
    final admission = PluginAdmissionController(maxConcurrent: 1);
    final startMessages = <Map<String, Object?>>[];

    Future<Isolate> spawner(
      Map<String, Object?> message,
      Future<Isolate> Function() spawn,
    ) {
      startMessages.add(Map<String, Object?>.of(message));
      return spawn();
    }

    final executor = _executor(
      _Host(),
      admission: admission,
      apiRegistry: apiRegistry,
      wireProtocols: wireProtocols,
    );
    final api1 = await runZoned(
      () => executor.invoke(_invocation(_artifact('echo'), params: 'api1')),
      zoneValues: {#pluginRuntimeWorkerSpawner: spawner},
    );
    final api2 = await runZoned(
      () => executor.invoke(_invocation(_artifact('apiVersionEcho'), params: 'api2')),
      zoneValues: {#pluginRuntimeWorkerSpawner: spawner},
    );

    expect(api1.result, 'api1');
    expect(api2.result, {'pluginApiVersion': 2, 'params': 'api2'});
    expect(admission.active, 0);
    expect(startMessages, hasLength(2));
    expect(
      startMessages,
      everyElement(
        allOf(
          isNot(contains('wireProtocol')),
          containsPair('wireProtocolIdentity', 'dev.shinga.plugin-wire.v1'),
          containsPair('wireProtocolVersion', 1),
        ),
      ),
    );
  });

  test('pre-cancellation avoids admission and worker execution', () async {
    final controller = PluginCancellationController()..cancel();
    final admission = PluginAdmissionController(maxConcurrent: 1);
    final executor = _executor(_Host(), admission: admission);

    final response = await executor.invoke(
      _invocation(_artifact('echo'), cancellationToken: controller.token),
    );

    expect(response.error?.category, PluginErrorCategory.cancelled);
    expect(admission.active, 0);
  });

  test('denies saturation immediately and releases after cancellation cleanup', () async {
    final host = _Host();
    final admission = PluginAdmissionController(maxConcurrent: 1);
    final executor = _executor(host, admission: admission);
    final controller = PluginCancellationController();
    final first = executor.invoke(
      _invocation(_artifact('hostNever'), cancellationToken: controller.token),
    );
    await host.started.future;

    final denied = await executor.invoke(_invocation(_artifact('echo')));
    controller.cancel();
    final cancelled = await first;

    expect(denied.error?.code, 'admission.saturated');
    expect(cancelled.error?.category, PluginErrorCategory.cancelled);
    expect(host.cancelCount, 1);
    expect(admission.active, 0);
  });

  test('hard deadline kills the worker and cancels pending host work', () async {
    final host = _Host();
    final admission = PluginAdmissionController(maxConcurrent: 1);

    final response = await _executor(host, admission: admission).invoke(
      _invocation(
        _artifact('hostNever'),
        hardDeadline: const Duration(milliseconds: 30),
      ),
    );

    expect(response.error?.category, PluginErrorCategory.timeout);
    expect(response.error?.code, 'invocation.hard_timeout');
    expect(host.cancelCount, 1);
    expect(admission.active, 0);
  });

  test('terminal response and admission release wait for bounded cleanup', () async {
    final cleanup = Completer<void>();
    final host = _Host(cleanup: cleanup);
    final admission = PluginAdmissionController(maxConcurrent: 1);
    final controller = PluginCancellationController();
    var completed = false;
    final future = _executor(host, admission: admission)
        .invoke(
          _invocation(_artifact('hostNever'), cancellationToken: controller.token),
        )
        .whenComplete(() => completed = true);
    await host.started.future;

    controller.cancel();
    await Future<void>.delayed(Duration.zero);

    expect(completed, isFalse);
    expect(admission.active, 1);
    cleanup.complete();
    final response = await future;
    expect(response.error?.category, PluginErrorCategory.cancelled);
    expect(admission.active, 0);
  });

  test('bounds a never-settling or throwing cancellation handle', () async {
    for (final host in [_Host(cancelNeverSettles: true), _Host(cancelThrows: true)]) {
      final controller = PluginCancellationController();
      final future = _executor(host).invoke(
        _invocation(_artifact('hostNever'), cancellationToken: controller.token),
      );
      await host.started.future;

      controller.cancel();
      final response = await future.timeout(const Duration(seconds: 1));

      expect(response.error?.category, PluginErrorCategory.cancelled);
      expect(host.cancelCount, 1);
    }
  });

  test('correlates sequential and concurrent generic worker host calls', () async {
    final host = _Host();
    final executor = _executor(host);

    final sequential = await executor.invoke(_invocation(_artifact('hostSequential')));
    final concurrent = await executor.invoke(_invocation(_artifact('hostConcurrent')));

    expect(sequential.result, [2, 4]);
    expect(concurrent.result, [2, 4, 6]);
    expect(host.requests.map((request) => request.callId), [
      'call-1',
      'call-2',
      'call-1',
      'call-2',
      'call-3',
    ]);
  });

  test('enforces pending and total host-call limits in the generic worker channel', () async {
    final pending = await _executor(_Host()).invoke(
      _invocation(
        _artifact('hostConcurrent'),
        maxPendingHostCalls: 1,
        maxTotalHostCalls: 3,
      ),
    );
    final total = await _executor(_Host()).invoke(
      _invocation(
        _artifact('hostSequential'),
        maxPendingHostCalls: 1,
        maxTotalHostCalls: 1,
      ),
    );

    expect((pending.result! as List<Object?>).skip(1), everyElement('host_call.limit_exceeded'));
    expect(total.result, [2, 'host_call.limit_exceeded']);
  });

  test('cancellation synchronously wins an already-queued host result', () async {
    final host = _Host();
    final controller = PluginCancellationController();
    final future = _executor(host).invoke(
      _invocation(_artifact('hostNever'), cancellationToken: controller.token),
    );
    await host.started.future;

    host.completeNever(42);
    controller.cancel();
    final response = await future;

    expect(response.error?.category, PluginErrorCategory.cancelled);
  });

  test('returns a safe failure when the artifact adapter is unavailable', () async {
    final registry = PluginRuntimeAdapterRegistry([const _FakeAdapter()]);
    final wireProtocols = PluginWireProtocolRegistry.builtIn();
    final executor = PluginRuntimeExecutor(
      apiRegistry: PluginApiRegistry.builtIn(wireProtocols),
      wireProtocols: wireProtocols,
      adapters: registry,
      admission: PluginAdmissionController(maxConcurrent: 1),
      hostCalls: _Host(),
    );

    final response = await executor.invoke(_invocation(_artifact('echo', adapterId: 'missing')));

    expect(response.error?.category, PluginErrorCategory.engineFailure);
    expect(response.error?.code, 'adapter.unavailable');
  });

  test('rejects unavailable API binding before admission or spawn', () async {
    final wireProtocols = PluginWireProtocolRegistry.builtIn();
    final admission = PluginAdmissionController(maxConcurrent: 1);
    var spawnCount = 0;
    final artifact = await _mintArtifact('echo', 'fixture');
    final executor = _executor(
      _Host(),
      admission: admission,
      apiRegistry: PluginApiRegistry(
        adapters: const [],
        wireProtocols: wireProtocols,
      ),
      wireProtocols: wireProtocols,
    );

    final response = await runZoned(
      () => executor.invoke(_invocation(artifact)),
      zoneValues: {
        #pluginRuntimeWorkerSpawner: (Future<Isolate> Function() spawn) {
          spawnCount += 1;
          return spawn();
        },
      },
    );

    expect(response.error?.code, 'api.unavailable');
    expect(admission.active, 0);
    expect(spawnCount, 0);
  });

  test('rejects mismatched API-to-wire artifact binding before admission', () async {
    final wireProtocols = PluginWireProtocolRegistry.builtIn();
    final admission = PluginAdmissionController(maxConcurrent: 1);
    final artifact = await _mintArtifact(
      'echo',
      'fixture',
      wireProtocolVersion: 2,
    );

    final response = await _executor(
      _Host(),
      admission: admission,
      wireProtocols: wireProtocols,
    ).invoke(_invocation(artifact));

    expect(response.error?.code, 'api.wire_binding_mismatch');
    expect(admission.active, 0);
  });

  test('rejects an unavailable wire codec before admission', () async {
    final inspectionWireProtocols = PluginWireProtocolRegistry.builtIn();
    final executionWireProtocols = PluginWireProtocolRegistry(const []);
    final admission = PluginAdmissionController(maxConcurrent: 1);

    final response = await _executor(
      _Host(),
      admission: admission,
      apiRegistry: PluginApiRegistry.builtIn(inspectionWireProtocols),
      wireProtocols: executionWireProtocols,
    ).invoke(_invocation(_artifact('echo')));

    expect(response.error?.code, 'wire_protocol.unavailable');
    expect(admission.active, 0);
  });

  test('rejects a registered codec unavailable to workers before spawn', () async {
    final wireProtocols = PluginWireProtocolRegistry(const [
      PluginWireProtocolV1(),
      _FixtureWireProtocol(2),
    ]);
    final apiRegistry = PluginApiRegistry(
      adapters: const [_FixtureApiAdapter(2, 2)],
      wireProtocols: wireProtocols,
    );
    final admission = PluginAdmissionController(maxConcurrent: 1);
    final artifact = await _mintArtifact(
      'echo',
      'fixture',
      pluginApiVersion: 2,
      wireProtocolVersion: 2,
    );
    var spawnCount = 0;

    final response = await runZoned(
      () => _executor(
        _Host(),
        admission: admission,
        apiRegistry: apiRegistry,
        wireProtocols: wireProtocols,
      ).invoke(_invocation(artifact)),
      zoneValues: {
        #pluginRuntimeWorkerSpawner: (Future<Isolate> Function() spawn) {
          spawnCount += 1;
          return spawn();
        },
      },
    );

    expect(response.error?.code, 'wire_protocol.worker_unavailable');
    expect(admission.active, 0);
    expect(spawnCount, 0);
  });

  test('rejects an incompatible wire1 codec before admission and spawn', () async {
    final wireProtocols = PluginWireProtocolRegistry(const [_FixtureWireProtocol(1)]);
    final admission = PluginAdmissionController(maxConcurrent: 1);
    var spawnCount = 0;

    final response = await runZoned(
      () => _executor(
        _Host(),
        admission: admission,
        apiRegistry: PluginApiRegistry.builtIn(wireProtocols),
        wireProtocols: wireProtocols,
      ).invoke(_invocation(_artifact('echo'))),
      zoneValues: {
        #pluginRuntimeWorkerSpawner: (Future<Isolate> Function() spawn) {
          spawnCount += 1;
          return spawn();
        },
      },
    );

    expect(response.error?.code, 'wire_protocol.worker_unavailable');
    expect(admission.active, 0);
    expect(spawnCount, 0);
  });

  test('worker exact-rejects a mismatched scalar codec identity', () async {
    Future<Isolate> spawner(
      Map<String, Object?> message,
      Future<Isolate> Function() spawn,
    ) {
      message['wireProtocolIdentity'] = 'dev.shinga.plugin-wire.v2';
      return spawn();
    }

    final response = await runZoned(
      () => _executor(_Host()).invoke(_invocation(_artifact('echo'))),
      zoneValues: {#pluginRuntimeWorkerSpawner: spawner},
    );

    expect(response.error?.category, PluginErrorCategory.engineFailure);
    expect(response.error?.code, 'worker.failure');
  });

  test('contains a worker entrypoint getter failure through terminal cleanup', () async {
    final admission = PluginAdmissionController(maxConcurrent: 1);
    final executor = _executor(
      _Host(),
      admission: admission,
      adapter: const _FakeAdapter('fixture', true),
    );
    var completionCount = 0;

    final response = await executor
        .invoke(
          _invocation(
            _artifact('echo'),
            hardDeadline: const Duration(milliseconds: 30),
          ),
        )
        .whenComplete(() => completionCount += 1);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(response.error?.category, PluginErrorCategory.engineFailure);
    expect(response.error?.code, 'adapter.payload_invalid');
    expect(completionCount, 1);
    expect(admission.active, 0);
  });

  test('rejects a malformed worker message and ignores later worker output', () async {
    Future<Isolate> spawner(
      Map<String, Object?> message,
      Future<Isolate> Function() _,
    ) {
      return Isolate.spawn<Map<String, Object?>>(_sendMalformedWorkerMessage, message);
    }

    final response = await runZoned(
      () => _executor(_Host()).invoke(_invocation(_artifact('echo'))),
      zoneValues: {#pluginRuntimeWorkerSpawner: spawner},
    );

    expect(response.error?.category, PluginErrorCategory.engineFailure);
    expect(response.error?.code, 'worker.message_invalid');
  });
}

void _sendMalformedWorkerMessage(Map<String, Object?> start) {
  (start['supervisorPort']! as SendPort)
    ..send('malformed')
    ..send(<String, Object?>{
      'type': 'terminal',
      'response': const PluginWireProtocolV1().encodeInvocationResponse(
        PluginInvocationResponse.success('late'),
      ),
    });
}

PluginRuntimeExecutor _executor(
  _Host host, {
  PluginAdmissionController? admission,
  PluginRuntimeAdapter adapter = const _FakeAdapter(),
  PluginApiRegistry? apiRegistry,
  PluginWireProtocolRegistry? wireProtocols,
}) {
  final selectedWireProtocols = wireProtocols ?? PluginWireProtocolRegistry.builtIn();
  return PluginRuntimeExecutor(
    apiRegistry: apiRegistry ?? PluginApiRegistry.builtIn(selectedWireProtocols),
    wireProtocols: selectedWireProtocols,
    adapters: PluginRuntimeAdapterRegistry([adapter]),
    admission: admission ?? PluginAdmissionController(maxConcurrent: 1),
    hostCalls: host,
  );
}

PluginInvocation _invocation(
  PluginExecutableArtifact artifact, {
  Object? params,
  Duration hardDeadline = const Duration(seconds: 1),
  PluginCancellationToken? cancellationToken,
  int maxPendingHostCalls = PluginProtocolLimits.maxPendingHostCalls,
  int maxTotalHostCalls = PluginProtocolLimits.maxTotalHostCalls,
}) {
  return PluginInvocation(
    artifact: artifact,
    request: PluginInvocationRequestV1(
      invocationId: 'invocation-${DateTime.now().microsecondsSinceEpoch}',
      pluginId: artifact.pluginId,
      pluginVersion: artifact.pluginVersion,
      pluginApiVersion: artifact.pluginApiVersion,
      method: 'run',
      params: params,
    ),
    limits: PluginInvocationLimits(
      hardDeadline: hardDeadline,
      maxPendingHostCalls: maxPendingHostCalls,
      maxTotalHostCalls: maxTotalHostCalls,
    ),
    cancellationToken: cancellationToken,
  );
}

PluginExecutableArtifact _artifact(String mode, {String adapterId = 'fixture'}) {
  return _artifacts['$adapterId:$mode']!;
}

Future<PluginExecutableArtifact> _mintArtifact(
  String mode,
  String adapterId, {
  int pluginApiVersion = 1,
  int wireProtocolVersion = 1,
}) async {
  final manifest = PluginManifest(
    manifestVersion: ManifestFormatVersion.tryParse(1)!,
    id: PluginId.tryParse('dev.shinga.fixture')!,
    name: 'Fixture',
    version: PluginVersion.tryParse('1.0.0')!,
    pluginApiVersion: PluginApiVersion.tryParse(pluginApiVersion)!,
    entry: PluginEntryPath.tryParse('index.fixture')!,
    permissions: const PluginPermissions(),
    settings: const [],
  );
  final result = await const PluginPackageValidator().validate(
    MemoryPluginPackageReader(files: {'index.fixture': utf8.encode(mode)}),
    manifest,
    _FakeAdapter(adapterId),
    wireProtocolVersion: wireProtocolVersion,
  );
  return result.artifact!;
}

final class _FakeAdapter implements PluginRuntimeAdapter {
  const _FakeAdapter([
    this.id = 'fixture',
    this.throwsReadingWorkerEntrypoint = false,
  ]);

  @override
  final String id;

  final bool throwsReadingWorkerEntrypoint;

  @override
  Set<String> get entryExtensions => const {'.fixture'};

  @override
  Object? createWorkerPayload(PluginExecutableArtifact artifact) {
    return <String, Object?>{
      'mode': utf8.decode(artifact.copySourceBytes()[artifact.entryPath]!),
    };
  }

  @override
  Future<PluginArtifactBuildResult> inspect(
    PluginPackageReader package,
    PluginManifest manifest,
  ) async {
    return PluginArtifactBuildResult(
      diagnostics: const [],
      candidate: PluginArtifactCandidate(
        sourceBytes: {
          manifest.entry.value: Uint8List.fromList(
            await package.readBytes(manifest.entry.value, maxBytes: 32),
          ),
        },
      ),
    );
  }

  @override
  PluginWorkerEntrypoint get workerEntrypoint {
    if (throwsReadingWorkerEntrypoint) {
      throw StateError('private adapter entrypoint failure');
    }
    return _runFixtureWorker;
  }
}

Future<PluginInvocationResponse> _runFixtureWorker(
  PluginWorkerContext context,
  Object? payload,
) async {
  final mode = (payload! as Map<Object?, Object?>)['mode']! as String;
  switch (mode) {
    case 'echo':
      return PluginInvocationResponse.success(context.request.params);
    case 'failure':
      return PluginInvocationResponse.failure(
        PluginError(category: PluginErrorCategory.pluginException, code: 'fixture.failure'),
      );
    case 'apiVersionEcho':
      return PluginInvocationResponse.success({
        'pluginApiVersion': context.request.pluginApiVersion,
        'params': context.request.params,
      });
    case 'hostNever':
      final response = await context.hostCalls.call('never', null);
      return PluginInvocationResponse.success(response.result);
    case 'hostSequential':
      final first = await context.hostCalls.call('double', 1);
      final second = await context.hostCalls.call('double', 2);
      return PluginInvocationResponse.success([
        first.error?.code ?? first.result,
        second.error?.code ?? second.result,
      ]);
    case 'hostConcurrent':
      final responses = await Future.wait([
        context.hostCalls.call('double', 1),
        context.hostCalls.call('double', 2),
        context.hostCalls.call('double', 3),
      ]);
      return PluginInvocationResponse.success([
        for (final response in responses) response.error?.code ?? response.result,
      ]);
    default:
      throw StateError('Unknown fixture mode.');
  }
}

final class _FixtureApiAdapter implements PluginApiAdapter {
  const _FixtureApiAdapter(this.pluginApiVersion, this.wireProtocolVersion);

  @override
  final int pluginApiVersion;

  @override
  final int wireProtocolVersion;
}

final class _FixtureWireProtocol implements PluginWireProtocol {
  const _FixtureWireProtocol(this.version);

  static const _wire1 = PluginWireProtocolV1();

  @override
  final int version;

  @override
  PluginHostCallRequest createHostCallRequest({
    required String invocationId,
    required String callId,
    required String pluginId,
    required int pluginApiVersion,
    required String operation,
    required int deadlineEpochMilliseconds,
    required Object? payload,
  }) {
    return _wire1.createHostCallRequest(
      invocationId: invocationId,
      callId: callId,
      pluginId: pluginId,
      pluginApiVersion: pluginApiVersion,
      operation: operation,
      deadlineEpochMilliseconds: deadlineEpochMilliseconds,
      payload: payload,
    );
  }

  @override
  PluginHostCallResponse createHostCallFailure({
    required String callId,
    required PluginError error,
  }) => _wire1.createHostCallFailure(callId: callId, error: error);

  @override
  PluginInvocationResponse createInvocationFailure(PluginError error) {
    return _wire1.createInvocationFailure(error);
  }

  @override
  PluginHostCallRequest decodeHostCallRequest(Object? value) {
    return _wire1.decodeHostCallRequest(value);
  }

  @override
  PluginHostCallResponse decodeHostCallResponse(Object? value) {
    return _wire1.decodeHostCallResponse(value);
  }

  @override
  PluginInvocationRequest decodeInvocationRequest(Object? value) {
    return _wire1.decodeInvocationRequest(value);
  }

  @override
  PluginInvocationResponse decodeInvocationResponse(Object? value) {
    return _wire1.decodeInvocationResponse(value);
  }

  @override
  Map<String, Object?> encodeHostCallRequest(PluginHostCallRequest request) {
    return _wire1.encodeHostCallRequest(request);
  }

  @override
  Map<String, Object?> encodeHostCallResponse(PluginHostCallResponse response) {
    return _wire1.encodeHostCallResponse(response);
  }

  @override
  Map<String, Object?> encodeInvocationRequest(PluginInvocationRequest request) {
    return _wire1.encodeInvocationRequest(request);
  }

  @override
  Map<String, Object?> encodeInvocationResponse(PluginInvocationResponse response) {
    return _wire1.encodeInvocationResponse(response);
  }
}

final class _Host implements PluginHostCallHandler {
  _Host({
    this.cleanup,
    this.cancelNeverSettles = false,
    this.cancelThrows = false,
  });

  final Completer<void>? cleanup;
  final bool cancelNeverSettles;
  final bool cancelThrows;
  final Completer<void> started = Completer<void>();
  final Completer<PluginHostCallResponse> _neverResponse = Completer();
  final List<PluginHostCallRequest> requests = [];
  int cancelCount = 0;

  void completeNever(Object? result) {
    final request = requests.last;
    _neverResponse.complete(
      PluginHostCallResponse.success(callId: request.callId, result: result),
    );
  }

  @override
  PluginHostOperation start(PluginHostCallRequest request) {
    requests.add(request);
    if (request.operation == 'double') {
      return PluginHostOperation(
        response: Future.delayed(
          Duration(milliseconds: 4 - (request.payload! as int)),
          () => PluginHostCallResponse.success(
            callId: request.callId,
            result: (request.payload! as int) * 2,
          ),
        ),
      );
    }
    if (!started.isCompleted) started.complete();
    return PluginHostOperation(
      response: _neverResponse.future,
      onCancel: () {
        cancelCount += 1;
        if (cancelThrows) throw StateError('cancel failed');
        if (cancelNeverSettles) return Completer<void>().future;
        return cleanup?.future;
      },
    );
  }
}
