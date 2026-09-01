import 'dart:async';
import 'dart:typed_data';

import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/plugin_runtime.dart';
import 'package:plugin_runtime/plugin_runtime_testing.dart';
import 'package:test/test.dart';

void main() {
  group('PluginInvocationLimits', () {
    test('accepts exact positive minima and hard maxima', () {
      expect(
        PluginInvocationLimits(
          hardDeadline: const Duration(microseconds: 1),
          maxPendingHostCalls: 1,
          maxTotalHostCalls: 1,
        ).hardDeadline,
        const Duration(microseconds: 1),
      );
      expect(
        PluginInvocationLimits(hardDeadline: PluginRuntimeLimits.maxHardDeadline),
        isA<PluginInvocationLimits>()
            .having(
              (limits) => limits.maxPendingHostCalls,
              'maxPendingHostCalls',
              PluginProtocolLimits.maxPendingHostCalls,
            )
            .having(
              (limits) => limits.maxTotalHostCalls,
              'maxTotalHostCalls',
              PluginProtocolLimits.maxTotalHostCalls,
            ),
      );
    });

    test('rejects zero, negative, over-ceiling, and inverted limits', () {
      final invalid = <void Function()>[
        () => PluginInvocationLimits(hardDeadline: Duration.zero),
        () => PluginInvocationLimits(hardDeadline: const Duration(microseconds: -1)),
        () => PluginInvocationLimits(hardDeadline: const Duration(seconds: 31)),
        () => PluginInvocationLimits(
          hardDeadline: const Duration(seconds: 1),
          maxPendingHostCalls: PluginProtocolLimits.maxPendingHostCalls + 1,
        ),
        () => PluginInvocationLimits(
          hardDeadline: const Duration(seconds: 1),
          maxTotalHostCalls: PluginProtocolLimits.maxTotalHostCalls + 1,
        ),
        () => PluginInvocationLimits(
          hardDeadline: const Duration(seconds: 1),
          maxPendingHostCalls: 2,
          maxTotalHostCalls: 1,
        ),
      ];

      for (final create in invalid) {
        expect(create, throwsArgumentError);
      }
    });
  });

  test('admission has no queue and releases idempotently', () {
    final admission = PluginAdmissionController(maxConcurrent: 1);

    final lease = admission.tryAcquire();

    expect(lease, isNotNull);
    expect(admission.tryAcquire(), isNull);
    lease!
      ..release()
      ..release();
    expect(admission.active, 0);
    expect(admission.tryAcquire(), isNotNull);
  });

  test('admission accepts its hard maximum and rejects one beyond it', () {
    expect(
      PluginAdmissionController(maxConcurrent: PluginRuntimeLimits.maxConcurrency).maxConcurrent,
      PluginRuntimeLimits.maxConcurrency,
    );
    expect(
      () => PluginAdmissionController(maxConcurrent: PluginRuntimeLimits.maxConcurrency + 1),
      throwsArgumentError,
    );
  });

  test('cancellation token completes exactly once', () async {
    final controller = PluginCancellationController();
    var completions = 0;
    unawaited(controller.token.whenCancelled.then((_) => completions += 1));

    controller
      ..cancel()
      ..cancel();
    await controller.token.whenCancelled;
    await Future<void>.delayed(Duration.zero);

    expect(controller.token.isCancelled, isTrue);
    expect(completions, 1);
  });

  test('cancellation listeners claim synchronously and can unregister', () {
    final controller = PluginCancellationController();
    var observed = false;
    var unregisteredObserved = false;
    controller.token.register(() => observed = true);
    controller.token.register(() => unregisteredObserved = true).unregister();

    controller.cancel();

    expect(observed, isTrue);
    expect(unregisteredObserved, isFalse);
  });

  test('cancellation notifies every listener before rethrowing the first error', () {
    final controller = PluginCancellationController();
    final observations = <String>[];
    controller.token.register(() {
      observations.add('throwing');
      throw StateError('listener failed');
    });
    controller.token.register(() => observations.add('later'));

    expect(controller.cancel, throwsStateError);

    expect(controller.token.isCancelled, isTrue);
    expect(observations, ['throwing', 'later']);
  });

  test('invocation rejects identity drift from its inspected artifact', () async {
    final artifact = await _artifact();

    expect(
      () => PluginInvocation(
        artifact: artifact,
        request: PluginInvocationRequestV1(
          invocationId: 'id',
          pluginId: 'dev.shinga.other',
          pluginVersion: '1.0.0',
          pluginApiVersion: 1,
          method: 'run',
          params: null,
        ),
        limits: PluginInvocationLimits(hardDeadline: const Duration(seconds: 1)),
      ),
      throwsA(isA<PluginProtocolException>()),
    );
  });
}

Future<PluginExecutableArtifact> _artifact() async {
  final manifest = PluginManifest(
    manifestVersion: ManifestFormatVersion.tryParse(1)!,
    id: PluginId.tryParse('dev.shinga.fixture')!,
    name: 'Fixture',
    version: PluginVersion.tryParse('1.0.0')!,
    pluginApiVersion: PluginApiVersion.tryParse(1)!,
    entry: PluginEntryPath.tryParse('index.dart')!,
    permissions: const PluginPermissions(),
    settings: const [],
  );
  final result = await const PluginPackageValidator().validate(
    MemoryPluginPackageReader(
      files: {
        'index.dart': const [1],
      },
    ),
    manifest,
    const _InvocationFixtureAdapter(),
  );
  return result.artifact!;
}

final class _InvocationFixtureAdapter implements PluginRuntimeAdapter {
  const _InvocationFixtureAdapter();

  @override
  String get id => 'fixture';

  @override
  Set<String> get entryExtensions => const {'.dart'};

  @override
  Object? createWorkerPayload(PluginExecutableArtifact artifact) => null;

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
            await package.readBytes(manifest.entry.value, maxBytes: 1),
          ),
        },
      ),
    );
  }

  @override
  PluginWorkerEntrypoint get workerEntrypoint => _unusedWorker;
}

PluginInvocationResponseV1 _unusedWorker(PluginWorkerContext context, Object? payload) {
  return PluginInvocationResponseV1.success(null);
}
