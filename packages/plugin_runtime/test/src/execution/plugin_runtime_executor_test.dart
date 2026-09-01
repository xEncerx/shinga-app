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
  });

  test('executes adapter success and failure in runtime-created workers', () async {
    final executor = _executor(_Host());

    final success = await executor.invoke(_invocation(_artifact('echo'), params: {'value': 1}));
    final failure = await executor.invoke(_invocation(_artifact('failure')));

    expect(success.result, {'value': 1});
    expect(failure.error?.code, 'fixture.failure');
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
    final executor = PluginRuntimeExecutor(
      adapters: registry,
      admission: PluginAdmissionController(maxConcurrent: 1),
      hostCalls: _Host(),
    );

    final response = await executor.invoke(_invocation(_artifact('echo', adapterId: 'missing')));

    expect(response.error?.category, PluginErrorCategory.engineFailure);
    expect(response.error?.code, 'adapter.unavailable');
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
      'response': PluginInvocationResponseV1.success('late').toJson(),
    });
}

PluginRuntimeExecutor _executor(
  _Host host, {
  PluginAdmissionController? admission,
  PluginRuntimeAdapter adapter = const _FakeAdapter(),
}) {
  return PluginRuntimeExecutor(
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

Future<PluginExecutableArtifact> _mintArtifact(String mode, String adapterId) async {
  final manifest = PluginManifest(
    manifestVersion: ManifestFormatVersion.tryParse(1)!,
    id: PluginId.tryParse('dev.shinga.fixture')!,
    name: 'Fixture',
    version: PluginVersion.tryParse('1.0.0')!,
    pluginApiVersion: PluginApiVersion.tryParse(1)!,
    entry: PluginEntryPath.tryParse('index.fixture')!,
    permissions: const PluginPermissions(),
    settings: const [],
  );
  final result = await const PluginPackageValidator().validate(
    MemoryPluginPackageReader(files: {'index.fixture': utf8.encode(mode)}),
    manifest,
    _FakeAdapter(adapterId),
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

Future<PluginInvocationResponseV1> _runFixtureWorker(
  PluginWorkerContext context,
  Object? payload,
) async {
  final mode = (payload! as Map<Object?, Object?>)['mode']! as String;
  switch (mode) {
    case 'echo':
      return PluginInvocationResponseV1.success(context.request.params);
    case 'failure':
      return PluginInvocationResponseV1.failure(
        PluginError(category: PluginErrorCategory.pluginException, code: 'fixture.failure'),
      );
    case 'hostNever':
      final response = await context.hostCalls.call('never', null);
      return PluginInvocationResponseV1.success(response.result);
    case 'hostSequential':
      final first = await context.hostCalls.call('double', 1);
      final second = await context.hostCalls.call('double', 2);
      return PluginInvocationResponseV1.success([
        first.error?.code ?? first.result,
        second.error?.code ?? second.result,
      ]);
    case 'hostConcurrent':
      final responses = await Future.wait([
        context.hostCalls.call('double', 1),
        context.hostCalls.call('double', 2),
        context.hostCalls.call('double', 3),
      ]);
      return PluginInvocationResponseV1.success([
        for (final response in responses) response.error?.code ?? response.result,
      ]);
    default:
      throw StateError('Unknown fixture mode.');
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
  final Completer<PluginHostCallResponseV1> _neverResponse = Completer();
  final List<PluginHostCallRequestV1> requests = [];
  int cancelCount = 0;

  void completeNever(Object? result) {
    final request = requests.last;
    _neverResponse.complete(
      PluginHostCallResponseV1.success(callId: request.callId, result: result),
    );
  }

  @override
  PluginHostOperation start(PluginHostCallRequestV1 request) {
    requests.add(request);
    if (request.operation == 'double') {
      return PluginHostOperation(
        response: Future.delayed(
          Duration(milliseconds: 4 - (request.payload! as int)),
          () => PluginHostCallResponseV1.success(
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
