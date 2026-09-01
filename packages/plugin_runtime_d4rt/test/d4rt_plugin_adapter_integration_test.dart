import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/plugin_runtime.dart';
import 'package:plugin_runtime/plugin_runtime_testing.dart';
import 'package:plugin_runtime_d4rt/plugin_runtime_d4rt.dart';
import 'package:test/test.dart';

void main() {
  late Directory packageDirectory;
  late Uint8List fixtureSource;
  late PluginExecutableArtifact fixtureArtifact;

  setUpAll(() async {
    final packageLibraryUri = await Isolate.resolvePackageUri(
      Uri.parse('package:plugin_runtime_d4rt/plugin_runtime_d4rt.dart'),
    );
    if (packageLibraryUri == null) {
      throw StateError('Could not resolve the plugin_runtime_d4rt package.');
    }
    packageDirectory = File.fromUri(packageLibraryUri).parent.parent;
    fixtureSource = await File.fromUri(
      packageDirectory.uri.resolve('../../examples/plugins/minimal_source/index.dart'),
    ).readAsBytes();
    fixtureArtifact = await _artifact(fixtureSource);
  });

  test('executes committed sync and async host-call fixture flows', () async {
    final host = _FixtureHost();
    final executor = _executor(host);

    final echo = await executor.invoke(_invocation(fixtureArtifact, 'echo', {'value': 42}));
    final hostFlow = await executor.invoke(_invocation(fixtureArtifact, 'hostFlow', {'value': 2}));
    final rejection = await executor.invoke(_invocation(fixtureArtifact, 'hostRejection', null));

    expect(echo.result, {'value': 42});
    expect(hostFlow.result, [4, 5, 3]);
    expect(rejection.result, {'category': 'hostDenied', 'code': 'fixture.denied'});
    expect(host.requests.map((request) => request.operation), [
      'fixture.sync',
      'fixture.async',
      'fixture.async',
      'fixture.reject',
    ]);
    expect(host.requests.map((request) => request.pluginId).toSet(), {'dev.shinga.minimal'});
    expect(host.requests.map((request) => request.pluginApiVersion).toSet(), {1});
    expect(host.requests.map((request) => request.deadlineEpochMilliseconds).toSet(), hasLength(2));
  });

  test('executes only retained artifact bytes after source and filesystem mutation', () async {
    final directory = await Directory.systemTemp.createTemp('d4rt_artifact_bytes_');
    addTearDown(() => directory.delete(recursive: true));
    await File.fromUri(
      directory.uri.resolve(PluginPackageFormat.manifestPath),
    ).writeAsString('{}');
    final sourceFile = File.fromUri(directory.uri.resolve('index.dart'));
    await sourceFile.writeAsString("Object? run(Object? _) => 'inspected';");
    final adapter = D4rtPluginAdapter();
    final validation = await const PluginPackageValidator().validate(
      DirectoryPluginPackageReader(directory),
      _manifest('dev.shinga.retained-bytes'),
      adapter,
      wireProtocolVersion: 1,
    );
    final artifact = validation.artifact!;
    final exposedCopy = artifact.copySourceBytes();

    exposedCopy['index.dart']!.setAll(
      0,
      utf8.encode("Object? run(Object? _) => 'forged!!!';"),
    );
    await sourceFile.writeAsString("Object? run(Object? _) => 'filesystem';");
    final response = await _executor(_FixtureHost(), adapter: adapter).invoke(
      _invocation(artifact, 'run', null),
    );

    expect(response.result, 'inspected');
  });

  test('suppresses interpreted print without dispatching a host call', () async {
    final probePath = File.fromUri(
      packageDirectory.uri.resolve('test/fixtures/print_suppression_probe.dart'),
    ).path;

    final probe = await Process.run(
      Platform.resolvedExecutable,
      ['run', probePath],
      workingDirectory: packageDirectory.path,
    );
    final output = '${probe.stdout}\n${probe.stderr}';

    expect(probe.exitCode, 0, reason: output);
    expect(probe.stdout, contains('result=print-complete hostDispatches=0'));
    expect(output, isNot(contains('SHINGA_INTERPRETED_PRINT_MUST_BE_SUPPRESSED')));
  }, timeout: const Timeout(Duration(minutes: 2)));

  for (final method in ['infiniteWhile', 'infiniteFor', 'infiniteRecursion']) {
    test('$method reaches the mandatory execution limit', () async {
      final limited = await _configuredArtifact(fixtureSource, maxSteps: 100);
      final response = await _executor(_FixtureHost(), adapter: limited.adapter).invoke(
        _invocation(limited.artifact, method, null),
      );

      expect(response.error?.category, PluginErrorCategory.executionLimit);
      expect(
        const PluginWireProtocolV1().encodeInvocationResponse(response).toString(),
        isNot(contains('D4rt')),
      );
    });
  }

  test('cooperative D4rt timeout returns only a safe timeout', () async {
    final configured = await _configuredArtifact(
      fixtureSource,
      maxSteps: D4rtExecutionPolicy.maxAllowedSteps,
      timeout: const Duration(milliseconds: 1),
    );
    final response = await _executor(_FixtureHost(), adapter: configured.adapter).invoke(
      _invocation(
        configured.artifact,
        'infiniteWhile',
        null,
        hostDeadline: const Duration(seconds: 1),
      ),
    );

    expect(response.error?.category, PluginErrorCategory.timeout);
  });

  test('delayed spawn preserves a shorter configured cooperative timeout', () async {
    const configuredTimeout = Duration(milliseconds: 100);
    final configured = await _configuredArtifact(fixtureSource, timeout: configuredTimeout);
    Future<Isolate> spawner(Future<Isolate> Function() spawn) async {
      await Future<void>.delayed(const Duration(milliseconds: 25));
      return await spawn();
    }

    final evidence = await _observeWorkerExecution(
      () => _withWorkerSpawner(
        spawner,
        () => _executor(_FixtureHost(), adapter: configured.adapter).invoke(
          _invocation(
            configured.artifact,
            'echo',
            'ok',
            hostDeadline: const Duration(seconds: 1),
          ),
        ),
      ),
    );

    expect(evidence.response.result, 'ok');
    expect(evidence.observation['didExecute'], isTrue);
    expect(
      evidence.observation['cooperativeTimeoutMicroseconds'],
      configuredTimeout.inMicroseconds,
    );
    expect(
      evidence.observation['cooperativeTimeoutMicroseconds']! as int,
      inInclusiveRange(1, evidence.observation['remainingMicroseconds']! as int),
    );
  });

  test('delayed spawn clamps equal cooperative and hard deadlines', () async {
    const deadline = Duration(milliseconds: 500);
    Future<Isolate> spawner(Future<Isolate> Function() spawn) async {
      await Future<void>.delayed(const Duration(milliseconds: 25));
      return await spawn();
    }

    final evidence = await _observeWorkerExecution(
      () => _withWorkerSpawner(
        spawner,
        () => _executor(_FixtureHost()).invoke(
          _invocation(
            fixtureArtifact,
            'echo',
            'ok',
            hostDeadline: deadline,
          ),
        ),
      ),
    );
    final remaining = evidence.observation['remainingMicroseconds']! as int;
    final cooperative = evidence.observation['cooperativeTimeoutMicroseconds']! as int;

    expect(evidence.response.result, 'ok');
    expect(evidence.observation['didExecute'], isTrue);
    expect(remaining, inInclusiveRange(1, deadline.inMicroseconds - 1));
    expect(cooperative, remaining);
  });

  test('nonpositive worker deadline skips D4rt execution and times out', () async {
    final evidence = await _observeWorkerExecution(
      () => _executor(_FixtureHost()).invoke(
        _invocation(
          fixtureArtifact,
          'echo',
          'must not execute',
          hostDeadline: const Duration(seconds: 1),
        ),
      ),
      deadlineEpochMicroseconds: 0,
    );

    expect(evidence.observation['didExecute'], isFalse);
    expect(evidence.observation['remainingMicroseconds']! as int, lessThanOrEqualTo(0));
    expect(evidence.response.error?.category, PluginErrorCategory.timeout);
    expect(evidence.response.error?.code, 'invocation.hard_timeout');
  });

  test('hard deadline kills a never-settling worker and cancels its host operation', () async {
    final host = _FixtureHost();

    final response = await _executor(host).invoke(
      _invocation(
        fixtureArtifact,
        'cancellableHostCall',
        null,
        hostDeadline: const Duration(milliseconds: 100),
      ),
    );

    expect(response.error?.category, PluginErrorCategory.timeout);
    expect(host.cancelCount, 1);
  });

  test('external cancellation settles once and cancels pending host work', () async {
    final host = _FixtureHost();
    final controller = PluginCancellationController();
    final future = _executor(host).invoke(
      _invocation(
        fixtureArtifact,
        'cancellableHostCall',
        null,
        cancellationToken: controller.token,
      ),
    );
    await host.cancellableStarted.future;

    controller.cancel();
    final response = await future;

    expect(response.error?.category, PluginErrorCategory.cancelled);
    expect(host.cancelCount, 1);
  });

  test('host start reentrant cancellation cleans the returned operation once', () async {
    final evidence = await _reentrantCancelInvocation();

    expect(evidence.response.error?.category, PluginErrorCategory.cancelled);
    expect(evidence.host.startCount, 1);
    expect(evidence.host.cancelCount, 1);
    expect(evidence.host.cancelOwnershipInvocations, 1);
    expect(evidence.terminalCompletionCount, 1);
    expect(evidence.admission.active, 0);
    await _expectCollected(evidence.releasedReferences);
  });

  test('host start throw returns a safe rejection and releases admission', () async {
    final artifact = await _artifact(
      utf8.encode(
        "Future<Object?> run(Object? _) => __shingaHostCall('fixture.throw-start', null);",
      ),
      id: 'dev.shinga.throw-start',
    );
    final host = _ThrowingStartHost();
    final admission = PluginAdmissionController(maxConcurrent: 1);

    final response = await _executor(
      host,
      admission: admission,
    ).invoke(_invocation(artifact, 'run', null));

    expect(response.result, {
      'version': 1,
      'callId': 'call-1',
      'error': {'category': 'hostDenied', 'code': 'host_call.rejected'},
    });
    expect(host.startCount, 1);
    expect(admission.active, 0);
  });

  test('cancel cleanup isolates throwing and never-settling handles', () async {
    final evidence = await _cancelFailureInvocation();

    expect(evidence.response.error?.category, PluginErrorCategory.cancelled);
    expect(evidence.host.cancelInvocationCounts, {
      'fixture.cancel-sync-throw': 1,
      'fixture.cancel-async-throw': 1,
      'fixture.cancel-never': 1,
    });
    expect(evidence.host.neverCleanupOwnershipInvocations, 1);
    expect(evidence.terminalCompletionCount, 1);
    expect(evidence.admission.active, 0);
    await _expectCollected(evidence.releasedReferences);
  });

  test('cancel synchronously beats an already-queued host result', () async {
    final host = _FixtureHost();
    final controller = PluginCancellationController();
    controller.token.register(() => throw StateError('public listener failed'));
    final future = _executor(host).invoke(
      _invocation(
        fixtureArtifact,
        'cancellableHostCall',
        null,
        cancellationToken: controller.token,
      ),
    );
    await host.cancellableStarted.future;

    host.completeCancellable('late success');
    expect(controller.cancel, throwsStateError);
    final response = await future;

    expect(response.error?.category, PluginErrorCategory.cancelled);
  });

  test('cancel synchronously beats an already-due hard timeout', () async {
    final host = _FixtureHost();
    final controller = PluginCancellationController();
    controller.token.register(() => throw StateError('public listener failed'));
    final future = _executor(host).invoke(
      _invocation(
        fixtureArtifact,
        'cancellableHostCall',
        null,
        hostDeadline: const Duration(milliseconds: 250),
        cancellationToken: controller.token,
      ),
    );
    await host.cancellableStarted.future;

    sleep(const Duration(milliseconds: 300));
    expect(controller.cancel, throwsStateError);
    final response = await future;

    expect(response.error?.category, PluginErrorCategory.cancelled);
  });

  test('hard deadline settles and releases admission while spawn never settles', () async {
    final admission = PluginAdmissionController(maxConcurrent: 1);
    final spawn = Completer<Isolate>();
    Future<Isolate> spawner(Future<Isolate> Function() _) => spawn.future;
    final stopwatch = Stopwatch()..start();

    final response = await _withWorkerSpawner(
      spawner,
      () => _executor(_FixtureHost(), admission: admission).invoke(
        _invocation(
          fixtureArtifact,
          'echo',
          null,
          hostDeadline: const Duration(milliseconds: 20),
        ),
      ),
    );

    expect(response.error?.category, PluginErrorCategory.timeout);
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 1)));
    expect(admission.active, 0);
  });

  test('cancellation settles and releases admission while spawn never settles', () async {
    final admission = PluginAdmissionController(maxConcurrent: 1);
    final controller = PluginCancellationController();
    final spawnStarted = Completer<void>();
    final spawn = Completer<Isolate>();
    Future<Isolate> spawner(Future<Isolate> Function() _) {
      spawnStarted.complete();
      return spawn.future;
    }

    final future = _withWorkerSpawner(
      spawner,
      () => _executor(_FixtureHost(), admission: admission).invoke(
        _invocation(
          fixtureArtifact,
          'echo',
          null,
          cancellationToken: controller.token,
        ),
      ),
    );
    await spawnStarted.future;

    controller.cancel();
    final response = await future;

    expect(response.error?.category, PluginErrorCategory.cancelled);
    expect(admission.active, 0);
  });

  test('created worker exits before delayed outer spawn completion', () async {
    final host = _FixtureHost();
    final admission = PluginAdmissionController(maxConcurrent: 1);
    final releaseSpawn = Completer<void>();
    addTearDown(() {
      if (!releaseSpawn.isCompleted) releaseSpawn.complete();
    });
    final workerExit = ReceivePort();
    addTearDown(workerExit.close);
    final workerCreated = Completer<Isolate>();
    Future<Isolate> spawner(Future<Isolate> Function() spawn) async {
      final worker = await spawn();
      workerCreated.complete(worker);
      worker.addOnExitListener(workerExit.sendPort);
      await releaseSpawn.future;
      return worker;
    }

    final future = _withWorkerSpawner(
      spawner,
      () => _executor(host, admission: admission).invoke(
        _invocation(
          fixtureArtifact,
          'cancellableHostCall',
          null,
          hostDeadline: const Duration(seconds: 1),
        ),
      ),
    );
    await host.cancellableStarted.future;

    final response = await future;
    final worker = await workerCreated.future;
    final pong = ReceivePort();
    addTearDown(pong.close);
    worker.ping(pong.sendPort);

    expect(response.error?.category, PluginErrorCategory.timeout);
    expect(admission.active, 0);
    expect(releaseSpawn.isCompleted, isFalse);
    await expectLater(
      pong.first.timeout(const Duration(milliseconds: 50)),
      throwsA(isA<TimeoutException>()),
    );
    releaseSpawn.complete();
    await workerExit.first.timeout(const Duration(seconds: 1));
    expect(host.cancelCount, 1);
  });

  test('worker result after absolute expiry cannot beat the armed deadline', () async {
    final delayed = await _artifact(
      utf8.encode('''
Future<Object?> run(Object? value) async {
  await Future<void>.delayed(const Duration(milliseconds: 40));
  return value;
}
'''),
      id: 'dev.shinga.expired-result',
    );
    final releaseSpawn = Completer<void>();
    Future<Isolate> spawner(Future<Isolate> Function() spawn) async {
      final worker = await spawn();
      await releaseSpawn.future;
      return worker;
    }

    final response = await _withWorkerSpawner(
      spawner,
      () => _executor(_FixtureHost()).invoke(
        _invocation(
          delayed,
          'run',
          'late',
          hostDeadline: const Duration(milliseconds: 20),
        ),
      ),
    );
    releaseSpawn.complete();

    expect(response.error?.category, PluginErrorCategory.timeout);
  });

  test('saturation denies immediately without a queue and later releases admission', () async {
    final host = _FixtureHost();
    final admission = PluginAdmissionController(maxConcurrent: 1);
    final executor = _executor(host, admission: admission);
    final controller = PluginCancellationController();
    final running = executor.invoke(
      _invocation(
        fixtureArtifact,
        'cancellableHostCall',
        null,
        cancellationToken: controller.token,
      ),
    );
    await host.cancellableStarted.future;

    final denied = await executor.invoke(_invocation(fixtureArtifact, 'echo', null));
    controller.cancel();
    await running;

    expect(denied.error?.category, PluginErrorCategory.hostDenied);
    expect(denied.error?.code, 'admission.saturated');
    expect(admission.active, 0);
  });

  test('fresh workers isolate globals across sequential and concurrent invocations', () async {
    final executor = _executor(_FixtureHost(), concurrency: 2);

    final sequentialFirst = await executor.invoke(
      _invocation(fixtureArtifact, 'stateIsolation', null),
    );
    final sequentialSecond = await executor.invoke(
      _invocation(fixtureArtifact, 'stateIsolation', null),
    );
    final concurrent = await Future.wait([
      executor.invoke(_invocation(fixtureArtifact, 'stateIsolation', null)),
      executor.invoke(_invocation(fixtureArtifact, 'stateIsolation', null)),
    ]);

    expect(sequentialFirst.result, 1);
    expect(sequentialSecond.result, 1);
    expect(concurrent.map((response) => response.result), [1, 1]);
  });

  test('invalid output and plugin exceptions expose only stable safe errors', () async {
    final invalidOutput = await _artifact(
      utf8.encode("Object? run(Object? _) => 'a' * 70000;"),
      id: 'dev.shinga.output',
    );
    final throwing = await _artifact(
      utf8.encode("Object? run(Object? _) { throw StateError('secret'); }"),
      id: 'dev.shinga.throwing',
    );

    final outputResponse = await _executor(_FixtureHost()).invoke(
      _invocation(invalidOutput, 'run', null),
    );
    final exceptionResponse = await _executor(_FixtureHost()).invoke(
      _invocation(throwing, 'run', null),
    );

    expect(outputResponse.error?.category, PluginErrorCategory.protocolViolation);
    expect(exceptionResponse.error?.category, PluginErrorCategory.pluginException);
    final encodedException = const PluginWireProtocolV1()
        .encodeInvocationResponse(exceptionResponse)
        .toString();
    expect(encodedException, isNot(contains('secret')));
    expect(encodedException, isNot(contains('StateError')));
  });

  test('worker bounds total calls, pending calls, operation IDs, and payloads', () async {
    final totalSource = await _artifact(
      utf8.encode('''
Future<Object?> run(Object? _) async {
  final first = await __shingaHostCall('fixture.sync', 0);
  final second = await __shingaHostCall('fixture.sync', 1);
  final third = await __shingaHostCall('fixture.sync', 2);
  return [first, second, third];
}
'''),
      id: 'dev.shinga.call-total',
    );
    final pendingSource = await _artifact(
      utf8.encode('''
Future<Object?> run(Object? _) async => Future.wait([
  __shingaHostCall('fixture.async', 1),
  __shingaHostCall('fixture.async', 2),
]);
'''),
      id: 'dev.shinga.call-pending',
    );
    final invalidPayloadSource = await _artifact(
      utf8.encode(
        "Future<Object?> run(Object? _) => __shingaHostCall('fixture.sync', 'a' * 70000);",
      ),
      id: 'dev.shinga.call-payload',
    );
    final invalidOperationSource = await _artifact(
      utf8.encode(
        "Future<Object?> run(Object? _) => __shingaHostCall('${'a' * 129}', null);",
      ),
      id: 'dev.shinga.call-operation',
    );
    final totalHost = _FixtureHost();
    final totalResponse = await _executor(totalHost).invoke(
      _invocation(
        totalSource,
        'run',
        null,
        maxPendingHostCalls: 2,
        maxTotalHostCalls: 2,
      ),
    );
    final pendingResponse = await _executor(_FixtureHost()).invoke(
      _invocation(pendingSource, 'run', null, maxPendingHostCalls: 1),
    );
    final payloadResponse = await _executor(_FixtureHost()).invoke(
      _invocation(invalidPayloadSource, 'run', null),
    );
    final operationResponse = await _executor(_FixtureHost()).invoke(
      _invocation(invalidOperationSource, 'run', null),
    );

    expect(totalResponse.error?.category, isNull);
    expect(totalHost.requests, hasLength(2));
    expect((totalResponse.result! as List<Object?>).last, {
      'version': 1,
      'callId': 'call-3',
      'error': {'category': 'hostDenied', 'code': 'host_call.limit_exceeded'},
    });
    expect((pendingResponse.result! as List<Object?>).last, {
      'version': 1,
      'callId': 'call-2',
      'error': {'category': 'hostDenied', 'code': 'host_call.limit_exceeded'},
    });
    expect(payloadResponse.result, {
      'version': 1,
      'callId': 'call-1',
      'error': {'category': 'protocolViolation', 'code': 'host_call.payload_invalid'},
    });
    expect(operationResponse.result, {
      'version': 1,
      'callId': 'call-1',
      'error': {'category': 'protocolViolation', 'code': 'host_call.payload_invalid'},
    });
  });

  test('accepts 32 pending calls and denies call 33 without host dispatch', () async {
    final source = await _artifact(
      utf8.encode('''
Future<Object?> run(Object? _) => Future.wait([
  ${List<String>.generate(33, (index) => "__shingaHostCall('fixture.pending', $index)").join(',\n  ')},
]);
'''),
      id: 'dev.shinga.pending-maximum',
    );
    final host = _PendingLimitHost();

    final response = await _executor(host).invoke(
      _invocation(source, 'run', null),
    );

    final results = response.result! as List<Object?>;
    expect(host.requests, hasLength(PluginProtocolLimits.maxPendingHostCalls));
    expect(
      results.take(32).map((value) => (value! as Map<Object?, Object?>)['result']),
      List<Object?>.generate(32, (index) => index),
    );
    expect(
      results.take(32).map((value) => (value! as Map<Object?, Object?>)['callId']),
      List<String>.generate(32, (index) => 'call-${index + 1}'),
    );
    expect(results.last, {
      'version': 1,
      'callId': 'call-33',
      'error': {'category': 'hostDenied', 'code': 'host_call.limit_exceeded'},
    });
  });

  test('accepts 256 total calls and denies call 257 without host dispatch', () async {
    final configured = await _configuredArtifact(
      utf8.encode('''
Future<Object?> run(Object? _) async {
  Object? response;
  for (var index = 0; index < 257; index += 1) {
    response = await __shingaHostCall('fixture.sync', index);
  }
  return response;
}
'''),
      id: 'dev.shinga.total-maximum',
      maxSteps: 1000000,
      timeout: const Duration(seconds: 30),
    );
    final host = _FixtureHost();

    final response = await _executor(host, adapter: configured.adapter).invoke(
      _invocation(
        configured.artifact,
        'run',
        null,
        hostDeadline: const Duration(seconds: 30),
      ),
    );

    expect(host.requests, hasLength(PluginProtocolLimits.maxTotalHostCalls));
    expect(response.result, {
      'version': 1,
      'callId': 'call-257',
      'error': {'category': 'hostDenied', 'code': 'host_call.limit_exceeded'},
    });
  });

  test('rejects a host response whose inherited call identity drifts', () async {
    final source = await _artifact(
      utf8.encode(
        "Future<Object?> run(Object? _) => __shingaHostCall('fixture.wrong-id', null);",
      ),
      id: 'dev.shinga.response-correlation',
    );

    final response = await _executor(
      const _WrongCorrelationHost(),
    ).invoke(_invocation(source, 'run', null));

    expect(response.result, {
      'version': 1,
      'callId': 'call-1',
      'error': {
        'category': 'protocolViolation',
        'code': 'host_call.response_scope_invalid',
      },
    });
  });

  test('repeated invocations release all admission capacity', () async {
    final admission = PluginAdmissionController(maxConcurrent: 2);
    final executor = _executor(_FixtureHost(), admission: admission);

    for (var index = 0; index < 25; index += 1) {
      final response = await executor.invoke(_invocation(fixtureArtifact, 'echo', index));
      expect(response.result, index);
    }

    expect(admission.active, 0);
  });

  test('never-settling host futures release invocation-owned source graphs', () async {
    final host = _FixtureHost();
    final admission = PluginAdmissionController(maxConcurrent: 1);
    final executor = _executor(host, admission: admission);
    final references = <WeakReference<Object>>[];

    for (var index = 0; index < 8; index += 1) {
      references.addAll(await _cancelEphemeralInvocation(executor, host, index));
      expect(admission.active, 0);
    }

    await _expectCollected(references);
    expect(host.cancelCount, 8);
    expect(host.unsettledCancellableCalls, 8);
  });

  test('worker terminal error survives its immediate isolate exit', () async {
    final throwing = await _artifact(
      utf8.encode("Object? run(Object? _) { throw StateError('private'); }"),
      id: 'dev.shinga.exit-order',
    );
    final executor = _executor(_FixtureHost(), concurrency: 2);

    final responses = <PluginInvocationResponse>[];
    for (var index = 0; index < 20; index += 1) {
      responses.add(await executor.invoke(_invocation(throwing, 'run', index)));
    }

    expect(
      responses.map((response) => response.error?.category),
      everyElement(PluginErrorCategory.pluginException),
    );
  });

  test('timeout/result races settle exactly once', () async {
    final admission = PluginAdmissionController(maxConcurrent: 1);
    final executor = _executor(_FixtureHost(), admission: admission);
    final delayed = await _artifact(
      utf8.encode('''
Future<Object?> run(Object? value) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  return value;
}
'''),
      id: 'dev.shinga.timeout-race',
    );
    for (var index = 0; index < 5; index += 1) {
      final response = await executor.invoke(
        _invocation(
          delayed,
          'run',
          index,
          hostDeadline: const Duration(milliseconds: 20),
        ),
      );
      expect(
        response.isSuccess || response.error?.category == PluginErrorCategory.timeout,
        isTrue,
      );
      expect(admission.active, 0);
    }
  });
}

typedef _TestWorkerSpawner = Future<Isolate> Function(Future<Isolate> Function() spawn);

Future<({PluginInvocationResponse response, Map<Object?, Object?> observation})>
_observeWorkerExecution(
  Future<PluginInvocationResponse> Function() body, {
  int? deadlineEpochMicroseconds,
}) async {
  final observations = ReceivePort();
  try {
    final observation = observations.first;
    final response = await runZoned(
      body,
      zoneValues: {
        #pluginRuntimeD4rtExecutionObserver: observations.sendPort,
        #pluginRuntimeWorkerDeadlineEpochMicroseconds: ?deadlineEpochMicroseconds,
      },
    );
    return (
      response: response,
      observation: await observation.timeout(const Duration(seconds: 1)) as Map<Object?, Object?>,
    );
  } finally {
    observations.close();
  }
}

Future<T> _withWorkerSpawner<T>(
  _TestWorkerSpawner spawner,
  Future<T> Function() body,
) {
  return runZoned(
    body,
    zoneValues: {#pluginRuntimeWorkerSpawner: spawner},
  );
}

PluginRuntimeExecutor _executor(
  PluginHostCallHandler host, {
  int concurrency = 1,
  D4rtPluginAdapter? adapter,
  PluginAdmissionController? admission,
}) {
  final wireProtocols = PluginWireProtocolRegistry.builtIn();
  return PluginRuntimeExecutor(
    apiRegistry: PluginApiRegistry.builtIn(wireProtocols),
    wireProtocols: wireProtocols,
    adapters: PluginRuntimeAdapterRegistry([adapter ?? D4rtPluginAdapter()]),
    admission: admission ?? PluginAdmissionController(maxConcurrent: concurrency),
    hostCalls: host,
  );
}

PluginInvocation _invocation(
  PluginExecutableArtifact artifact,
  String method,
  Object? params, {
  Duration hostDeadline = const Duration(seconds: 3),
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
      method: method,
      params: params,
    ),
    limits: PluginInvocationLimits(
      hardDeadline: hostDeadline,
      maxPendingHostCalls: maxPendingHostCalls,
      maxTotalHostCalls: maxTotalHostCalls,
    ),
    cancellationToken: cancellationToken,
  );
}

Future<PluginExecutableArtifact> _artifact(
  List<int> source, {
  String id = 'dev.shinga.minimal',
  int maxSteps = 100000,
  Duration timeout = const Duration(seconds: 2),
}) async {
  return (await _configuredArtifact(
    source,
    id: id,
    maxSteps: maxSteps,
    timeout: timeout,
  )).artifact;
}

Future<({PluginExecutableArtifact artifact, D4rtPluginAdapter adapter})> _configuredArtifact(
  List<int> source, {
  String id = 'dev.shinga.minimal',
  int maxSteps = 100000,
  Duration timeout = const Duration(seconds: 2),
}) async {
  final manifest = _manifest(id);
  final adapter = D4rtPluginAdapter(
    policy: D4rtExecutionPolicy(maxSteps: maxSteps, timeout: timeout),
  );
  final result = await const PluginPackageValidator().validate(
    MemoryPluginPackageReader(files: {'index.dart': source}),
    manifest,
    adapter,
    wireProtocolVersion: 1,
  );
  expect(result.diagnostics, isEmpty);
  return (artifact: result.artifact!, adapter: adapter);
}

PluginManifest _manifest(String id) => PluginManifest(
  manifestVersion: ManifestFormatVersion.tryParse(1)!,
  id: PluginId.tryParse(id)!,
  name: 'Fixture',
  version: PluginVersion.tryParse('1.0.0')!,
  pluginApiVersion: PluginApiVersion.tryParse(1)!,
  entry: PluginEntryPath.tryParse('index.dart')!,
  permissions: const PluginPermissions(),
  settings: const [],
);

final class _FixtureHost implements PluginHostCallHandler {
  final List<PluginHostCallRequest> requests = [];
  final Completer<void> cancellableStarted = Completer<void>();
  final List<Completer<PluginHostCallResponse>> _cancellableResponses = [];
  int cancelCount = 0;

  int get unsettledCancellableCalls =>
      _cancellableResponses.where((completer) => !completer.isCompleted).length;

  void completeCancellable(Object? result) {
    _cancellableResponses.last.complete(
      PluginHostCallResponse.success(
        callId: requests.last.callId,
        result: result,
      ),
    );
  }

  @override
  PluginHostOperation start(PluginHostCallRequest request) {
    requests.add(request);
    switch (request.operation) {
      case 'fixture.sync':
        return PluginHostOperation.completed(
          PluginHostCallResponse.success(
            callId: request.callId,
            result: (request.payload! as int) * 2,
          ),
        );
      case 'fixture.async':
        return PluginHostOperation(
          response: Future<PluginHostCallResponse>.delayed(
            const Duration(milliseconds: 5),
            () => PluginHostCallResponse.success(
              callId: request.callId,
              result: (request.payload! as int) + 1,
            ),
          ),
        );
      case 'fixture.reject':
        return PluginHostOperation.completed(
          PluginHostCallResponse.failure(
            callId: request.callId,
            error: PluginError(
              category: PluginErrorCategory.hostDenied,
              code: 'fixture.denied',
            ),
          ),
        );
      case 'fixture.cancellable':
        if (!cancellableStarted.isCompleted) cancellableStarted.complete();
        final response = Completer<PluginHostCallResponse>();
        _cancellableResponses.add(response);
        return PluginHostOperation(
          response: response.future,
          onCancel: () => cancelCount += 1,
        );
    }
    return PluginHostOperation.completed(
      PluginHostCallResponse.failure(
        callId: request.callId,
        error: PluginError(
          category: PluginErrorCategory.hostDenied,
          code: 'fixture.unknown',
        ),
      ),
    );
  }
}

final class _PendingLimitHost implements PluginHostCallHandler {
  final List<PluginHostCallRequest> requests = [];
  final List<Completer<PluginHostCallResponse>> _responses = [];

  @override
  PluginHostOperation start(PluginHostCallRequest request) {
    requests.add(request);
    final response = Completer<PluginHostCallResponse>();
    _responses.add(response);
    if (requests.length == PluginProtocolLimits.maxPendingHostCalls) {
      scheduleMicrotask(() {
        for (var index = 0; index < _responses.length; index += 1) {
          _responses[index].complete(
            PluginHostCallResponse.success(
              callId: requests[index].callId,
              result: requests[index].payload,
            ),
          );
        }
      });
    }
    return PluginHostOperation(response: response.future);
  }
}

final class _WrongCorrelationHost implements PluginHostCallHandler {
  const _WrongCorrelationHost();

  @override
  PluginHostOperation start(PluginHostCallRequest request) {
    return PluginHostOperation.completed(
      PluginHostCallResponse.success(
        callId: 'call-wrong',
        result: request.payload,
      ),
    );
  }
}

final class _ThrowingStartHost implements PluginHostCallHandler {
  int startCount = 0;

  @override
  PluginHostOperation start(PluginHostCallRequest request) {
    startCount += 1;
    throw StateError('private synchronous start failure');
  }
}

final class _ReentrantCancelHost implements PluginHostCallHandler {
  _ReentrantCancelHost(this.controller);

  final PluginCancellationController controller;
  final Completer<PluginHostCallResponse> _response = Completer();
  final Completer<void> _neverCancelled = Completer<void>();
  final Completer<void> cancelInvoked = Completer<void>();
  WeakReference<Object>? cancelOwnershipReference;
  _ReentrantCancelOwnership? cancelOwnership;
  int startCount = 0;
  int cancelCount = 0;
  int cancelOwnershipInvocations = 0;

  @override
  PluginHostOperation start(PluginHostCallRequest request) {
    startCount += 1;
    controller.cancel();
    final ownership = _ReentrantCancelOwnership();
    cancelOwnership = ownership;
    cancelOwnershipReference = WeakReference<Object>(ownership);
    return PluginHostOperation(
      response: _response.future,
      onCancel: () {
        cancelCount += 1;
        ownership.markInvoked();
        cancelOwnershipInvocations += 1;
        if (!cancelInvoked.isCompleted) cancelInvoked.complete();
        return _neverCancelled.future;
      },
    );
  }
}

final class _ReentrantCancelOwnership {
  int invocationCount = 0;

  void markInvoked() {
    invocationCount += 1;
  }
}

final class _ReentrantCancelEvidence {
  const _ReentrantCancelEvidence({
    required this.host,
    required this.admission,
    required this.response,
    required this.terminalCompletionCount,
    required this.releasedReferences,
  });

  final _ReentrantCancelHost host;
  final PluginAdmissionController admission;
  final PluginInvocationResponse response;
  final int terminalCompletionCount;
  final List<WeakReference<Object>> releasedReferences;
}

Future<_ReentrantCancelEvidence> _reentrantCancelInvocation() async {
  final artifact = await _artifact(
    utf8.encode(
      "Future<Object?> run(Object? _) => __shingaHostCall('fixture.reentrant-cancel', null);",
    ),
    id: 'dev.shinga.reentrant-cancel',
  );
  final controller = PluginCancellationController();
  final host = _ReentrantCancelHost(controller);
  final admission = PluginAdmissionController(maxConcurrent: 1);
  final invocation = _invocation(
    artifact,
    'run',
    null,
    hostDeadline: const Duration(milliseconds: 200),
    cancellationToken: controller.token,
  );
  final releasedReferences = <WeakReference<Object>>[
    WeakReference<Object>(invocation),
    WeakReference<Object>(artifact),
  ];
  var terminalCompletionCount = 0;
  final future = _executor(host, admission: admission).invoke(invocation).then((
    response,
  ) {
    terminalCompletionCount += 1;
    return response;
  });

  final response = await future.timeout(const Duration(seconds: 1));
  await host.cancelInvoked.future.timeout(const Duration(seconds: 1));
  final cancelOwnership = host.cancelOwnership;
  final cancelOwnershipReference = host.cancelOwnershipReference;
  expect(cancelOwnership, isNotNull);
  expect(cancelOwnershipReference, isNotNull);
  expect(cancelOwnership!.invocationCount, 1);
  releasedReferences.add(cancelOwnershipReference!);
  host.cancelOwnership = null;
  await Future<void>.delayed(const Duration(milliseconds: 250));

  return _ReentrantCancelEvidence(
    host: host,
    admission: admission,
    response: response,
    terminalCompletionCount: terminalCompletionCount,
    releasedReferences: releasedReferences,
  );
}

final class _CancelFailureHost implements PluginHostCallHandler {
  final Completer<void> allStarted = Completer<void>();
  final Completer<void> allCancelHandlesInvoked = Completer<void>();
  final Map<String, int> cancelInvocationCounts = {};
  final List<Completer<PluginHostCallResponse>> _responses = [];
  final Completer<void> _neverCancelled = Completer<void>();
  WeakReference<Object>? cleanupOwnershipReference;
  _CancelCleanupOwnership? cleanupOwnership;
  int neverCleanupOwnershipInvocations = 0;

  @override
  PluginHostOperation start(PluginHostCallRequest request) {
    final response = Completer<PluginHostCallResponse>();
    _responses.add(response);
    if (_responses.length == 3) allStarted.complete();

    final cancel = switch (request.operation) {
      'fixture.cancel-sync-throw' => () {
        _recordCancel(request.operation);
        throw StateError('synchronous cancellation failure');
      },
      'fixture.cancel-async-throw' => () async {
        _recordCancel(request.operation);
        throw StateError('asynchronous cancellation failure');
      },
      'fixture.cancel-never' => _neverCancel(request.operation),
      _ => throw StateError('Unexpected operation: ${request.operation}'),
    };
    return PluginHostOperation(response: response.future, onCancel: cancel);
  }

  PluginHostOperationCancel _neverCancel(String operation) {
    final ownership = _CancelCleanupOwnership();
    cleanupOwnership = ownership;
    cleanupOwnershipReference = WeakReference<Object>(ownership);
    return () {
      _recordCancel(operation);
      ownership.markInvoked();
      neverCleanupOwnershipInvocations += 1;
      return _neverCancelled.future;
    };
  }

  void _recordCancel(String operation) {
    cancelInvocationCounts.update(operation, (count) => count + 1, ifAbsent: () => 1);
    if (cancelInvocationCounts.length == 3 && !allCancelHandlesInvoked.isCompleted) {
      allCancelHandlesInvoked.complete();
    }
  }
}

final class _CancelCleanupOwnership {
  int invocationCount = 0;

  void markInvoked() {
    invocationCount += 1;
  }
}

final class _CancelFailureEvidence {
  const _CancelFailureEvidence({
    required this.host,
    required this.admission,
    required this.response,
    required this.terminalCompletionCount,
    required this.releasedReferences,
  });

  final _CancelFailureHost host;
  final PluginAdmissionController admission;
  final PluginInvocationResponse response;
  final int terminalCompletionCount;
  final List<WeakReference<Object>> releasedReferences;
}

Future<_CancelFailureEvidence> _cancelFailureInvocation() async {
  final artifact = await _artifact(
    utf8.encode('''
Future<Object?> run(Object? _) => Future.wait([
  __shingaHostCall('fixture.cancel-sync-throw', null),
  __shingaHostCall('fixture.cancel-async-throw', null),
  __shingaHostCall('fixture.cancel-never', null),
]);
'''),
    id: 'dev.shinga.cancel-cleanup',
  );
  final host = _CancelFailureHost();
  final admission = PluginAdmissionController(maxConcurrent: 1);
  final controller = PluginCancellationController();
  final invocation = _invocation(
    artifact,
    'run',
    null,
    hostDeadline: const Duration(milliseconds: 200),
    cancellationToken: controller.token,
  );
  final releasedReferences = <WeakReference<Object>>[
    WeakReference<Object>(invocation),
    WeakReference<Object>(artifact),
  ];
  var terminalCompletionCount = 0;
  final future = _executor(host, admission: admission).invoke(invocation).then((
    response,
  ) {
    terminalCompletionCount += 1;
    return response;
  });
  await host.allStarted.future;

  controller
    ..cancel()
    ..cancel();
  final response = await future.timeout(const Duration(seconds: 1));
  await host.allCancelHandlesInvoked.future.timeout(const Duration(seconds: 1));
  final cleanupOwnership = host.cleanupOwnership;
  final cleanupOwnershipReference = host.cleanupOwnershipReference;
  expect(cleanupOwnership, isNotNull);
  expect(cleanupOwnershipReference, isNotNull);
  expect(cleanupOwnership!.invocationCount, 1);
  releasedReferences.add(cleanupOwnershipReference!);
  host.cleanupOwnership = null;
  await Future<void>.delayed(const Duration(milliseconds: 250));

  return _CancelFailureEvidence(
    host: host,
    admission: admission,
    response: response,
    terminalCompletionCount: terminalCompletionCount,
    releasedReferences: releasedReferences,
  );
}

Future<List<WeakReference<Object>>> _cancelEphemeralInvocation(
  PluginRuntimeExecutor executor,
  _FixtureHost host,
  int index,
) async {
  final artifact = await _artifact(
    utf8.encode(
      'Future<Object?> run(Object? value) => '
      '__shingaHostCall(value, null) as Future<Object?>;',
    ),
    id: 'dev.shinga.lifecycle-$index',
  );
  final controller = PluginCancellationController();
  final invocation = _invocation(
    artifact,
    'run',
    'fixture.cancellable',
    cancellationToken: controller.token,
  );
  final artifactReference = WeakReference<Object>(artifact);
  final invocationReference = WeakReference<Object>(invocation);
  final startedCount = host.requests.length;
  final future = executor.invoke(invocation);
  while (host.requests.length == startedCount) {
    await Future<void>.delayed(Duration.zero);
  }

  controller.cancel();
  final response = await future;

  expect(response.error?.category, PluginErrorCategory.cancelled);
  return [artifactReference, invocationReference];
}

Future<void> _expectCollected(List<WeakReference<Object>> references) async {
  for (var attempt = 0; attempt < 100; attempt += 1) {
    if (references.every((reference) => reference.target == null)) return;
    final pressure = List<Uint8List>.generate(8, (_) => Uint8List(1024 * 1024));
    pressure[attempt % pressure.length][0] = attempt;
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(
    references.where((reference) => reference.target != null),
    isEmpty,
    reason: 'Detached response continuations must not retain invocation resources.',
  );
}
