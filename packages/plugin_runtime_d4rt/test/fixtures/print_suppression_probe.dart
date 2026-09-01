import 'dart:convert';
import 'dart:io';

import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/plugin_runtime.dart';
import 'package:plugin_runtime/plugin_runtime_testing.dart';
import 'package:plugin_runtime_d4rt/plugin_runtime_d4rt.dart';

/// Runs the adapter in a child process so interpreted stdout can be observed.
Future<void> main() async {
  final manifest = PluginManifest(
    manifestVersion: ManifestFormatVersion.tryParse(1)!,
    id: PluginId.tryParse('dev.shinga.print-probe')!,
    name: 'Print probe',
    version: PluginVersion.tryParse('1.0.0')!,
    pluginApiVersion: PluginApiVersion.tryParse(1)!,
    entry: PluginEntryPath.tryParse('index.dart')!,
    permissions: const PluginPermissions(),
    settings: const [],
  );
  final adapter = D4rtPluginAdapter(
    policy: D4rtExecutionPolicy(
      maxSteps: 10000,
      timeout: const Duration(seconds: 2),
    ),
  );
  final artifact = (await const PluginPackageValidator().validate(
    MemoryPluginPackageReader(
      files: {
        'index.dart': utf8.encode('''
Object? run(Object? _) {
  print('SHINGA_INTERPRETED_PRINT_MUST_BE_SUPPRESSED');
  return 'print-complete';
}
'''),
      },
    ),
    manifest,
    adapter,
    wireProtocolVersion: 1,
  )).artifact!;
  final host = _CountingHost();
  final wireProtocols = PluginWireProtocolRegistry.builtIn();
  final response =
      await PluginRuntimeExecutor(
        apiRegistry: PluginApiRegistry.builtIn(wireProtocols),
        wireProtocols: wireProtocols,
        adapters: PluginRuntimeAdapterRegistry([adapter]),
        admission: PluginAdmissionController(maxConcurrent: 1),
        hostCalls: host,
      ).invoke(
        PluginInvocation(
          artifact: artifact,
          request: PluginInvocationRequestV1(
            invocationId: 'print-probe',
            pluginId: artifact.pluginId,
            pluginVersion: artifact.pluginVersion,
            pluginApiVersion: artifact.pluginApiVersion,
            method: 'run',
            params: null,
          ),
          limits: PluginInvocationLimits(hardDeadline: const Duration(seconds: 3)),
        ),
      );

  stdout.writeln('result=${response.result} hostDispatches=${host.dispatchCount}');
  if (response.result != 'print-complete' || response.error != null || host.dispatchCount != 0) {
    exitCode = 1;
  }
}

final class _CountingHost implements PluginHostCallHandler {
  int dispatchCount = 0;

  @override
  PluginHostOperation start(PluginHostCallRequest request) {
    dispatchCount += 1;
    return PluginHostOperation.completed(
      PluginHostCallResponse.failure(
        callId: request.callId,
        error: PluginError(
          category: PluginErrorCategory.hostDenied,
          code: 'print_probe.unexpected_host_call',
        ),
      ),
    );
  }
}
