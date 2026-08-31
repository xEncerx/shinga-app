import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/plugin_runtime.dart';
import 'package:plugin_runtime/plugin_runtime_testing.dart';
import 'package:plugin_runtime_d4rt/plugin_runtime_d4rt.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('executes a bounded interpreted-Dart method in a worker isolate', (tester) async {
    expect(tester.binding, isNotNull);
    final manifest = PluginManifest(
      manifestVersion: ManifestFormatVersion.tryParse(1)!,
      id: PluginId.tryParse('dev.shinga.platform-smoke')!,
      name: 'Platform smoke',
      version: PluginVersion.tryParse('1.0.0')!,
      pluginApiVersion: PluginApiVersion.tryParse(1)!,
      entry: PluginEntryPath.tryParse('index.dart')!,
      permissions: const PluginPermissions(),
      settings: const [],
    );
    final artifact = (await const PluginExecutableArtifactBuilder().build(
      MemoryPluginPackageReader(
        files: {
          'index.dart': utf8.encode('Object? echo(Object? value) => value;'),
        },
      ),
      manifest,
    )).artifact!;
    final executor = D4rtPluginExecutor(
      admission: PluginAdmissionController(maxConcurrent: 1),
      hostCalls: const _DeniedHostCalls(),
    );

    final response = await executor.invoke(
      PluginInvocation(
        artifact: artifact,
        request: PluginInvocationRequestV1(
          invocationId: 'platform-smoke',
          pluginId: artifact.pluginId,
          pluginVersion: artifact.pluginVersion,
          pluginApiVersion: artifact.pluginApiVersion,
          method: 'echo',
          params: const {'platform': 'worker-isolate'},
        ),
        limits: PluginInvocationLimits(
          maxSteps: 10000,
          timeout: const Duration(seconds: 2),
          hostHardDeadline: const Duration(seconds: 3),
        ),
      ),
    );

    expect(response.result, {'platform': 'worker-isolate'});
    expect(response.error, isNull);
  });
}

final class _DeniedHostCalls implements PluginHostCallHandler {
  const _DeniedHostCalls();

  @override
  PluginHostOperation start(PluginHostCallRequestV1 request) {
    return PluginHostOperation.completed(
      PluginHostCallResponseV1.failure(
        callId: request.callId,
        error: PluginError(
          category: PluginErrorCategory.hostDenied,
          code: 'smoke.no_host_calls',
        ),
      ),
    );
  }
}
