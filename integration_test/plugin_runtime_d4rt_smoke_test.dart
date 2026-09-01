import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/plugin_runtime.dart';
import 'package:plugin_runtime/plugin_runtime_testing.dart';
import 'package:plugin_runtime_d4rt/plugin_runtime_d4rt.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('inspects and executes a D4rt plugin through the shared runtime', (tester) async {
    expect(tester.binding, isNotNull);
    final parser = PluginManifestParser();
    final wireProtocols = PluginWireProtocolRegistry.builtIn();
    final apiRegistry = PluginApiRegistry.builtIn(wireProtocols);
    final adapters = PluginRuntimeAdapterRegistry([D4rtPluginAdapter()]);
    final inspector = PluginPackageInspector(
      manifestLoader: PluginManifestLoader(parser: parser),
      packageValidator: const PluginPackageValidator(),
      compatibilityPolicy: PluginCompatibilityPolicy(
        parser: parser,
        apiRegistry: apiRegistry,
      ),
      adapterRegistry: adapters,
    );
    final inspection = await inspector.inspect(
      MemoryPluginPackageReader(
        files: {
          PluginPackageFormat.manifestPath: utf8.encode(
            jsonEncode({
              'manifestVersion': 1,
              'id': 'dev.shinga.platform-smoke',
              'name': 'Platform smoke',
              'version': '1.0.0',
              'pluginApiVersion': 1,
              'entry': 'index.dart',
            }),
          ),
          'index.dart': utf8.encode('Object? echo(Object? value) => value;'),
        },
      ),
    );
    expect(inspection, isA<ValidPluginPackage>());
    final artifact = (inspection as ValidPluginPackage).artifact;
    expect(artifact.adapterId, 'd4rt');
    final executor = PluginRuntimeExecutor(
      apiRegistry: apiRegistry,
      wireProtocols: wireProtocols,
      adapters: adapters,
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
        limits: PluginInvocationLimits(hardDeadline: const Duration(seconds: 3)),
      ),
    );

    expect(response.result, {'platform': 'worker-isolate'});
    expect(response.error, isNull);
  });
}

final class _DeniedHostCalls implements PluginHostCallHandler {
  const _DeniedHostCalls();

  @override
  PluginHostOperation start(PluginHostCallRequest request) {
    return PluginHostOperation.completed(
      PluginHostCallResponse.failure(
        callId: request.callId,
        error: PluginError(
          category: PluginErrorCategory.hostDenied,
          code: 'smoke.no_host_calls',
        ),
      ),
    );
  }
}
