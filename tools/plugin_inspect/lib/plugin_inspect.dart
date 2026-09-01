import 'dart:io';

import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/plugin_runtime.dart';
import 'package:plugin_runtime_d4rt/plugin_runtime_d4rt.dart';

/// Runs the plugin package inspector CLI and returns its process exit code.
Future<int> runPluginInspect(
  List<String> arguments, {
  StringSink? output,
  StringSink? errorOutput,
}) async {
  final stdoutSink = output ?? stdout;
  final stderrSink = errorOutput ?? stderr;
  if (arguments.length != 1 || arguments.single.startsWith('-')) {
    stderrSink.writeln(
      'Usage: dart run tools/plugin_inspect/bin/plugin_inspect.dart <plugin-directory>',
    );
    return 2;
  }

  final directory = Directory(arguments.single);
  if (!directory.existsSync()) {
    stderrSink.writeln('Plugin directory does not exist: ${directory.path}');
    return 2;
  }

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
    DirectoryPluginPackageReader(directory),
  );
  switch (inspection) {
    case ValidPluginPackage(:final manifest, :final diagnostics):
      _writeManifest(stdoutSink, manifest);
      if (diagnostics.isNotEmpty) {
        stdoutSink.writeln();
        _writeDiagnostics(stdoutSink, diagnostics);
      }
      stdoutSink
        ..writeln()
        ..writeln('Package is structurally valid.');
      return 0;
    case InvalidPluginPackage(:final diagnostics):
      _writeDiagnostics(stderrSink, diagnostics);
      return 1;
  }
}

void _writeManifest(StringSink output, PluginManifest manifest) {
  final hosts = manifest.permissions.network?.hosts ?? const [];
  output
    ..writeln('Plugin: ${manifest.id}')
    ..writeln('Version: ${manifest.version}')
    ..writeln('Plugin API: ${manifest.pluginApiVersion}')
    ..writeln('Entry: ${manifest.entry}')
    ..writeln('Settings: ${manifest.settings.length}')
    ..writeln('Network hosts: ${hosts.isEmpty ? 'none' : hosts.join(', ')}');
}

void _writeDiagnostics(StringSink output, List<PluginDiagnostic> diagnostics) {
  for (final (index, diagnostic) in diagnostics.indexed) {
    if (index > 0) {
      output.writeln();
    }
    output
      ..writeln('${diagnostic.severity.name.toUpperCase()} ${_location(diagnostic)}')
      ..writeln(diagnostic.code)
      ..writeln()
      ..writeln(diagnostic.message);
  }
}

String _location(PluginDiagnostic diagnostic) {
  if (diagnostic is ManifestDiagnostic) {
    return diagnostic.path.toString();
  }
  if (diagnostic is PackageDiagnostic) {
    return diagnostic.manifestPath?.toString() ?? diagnostic.relativePath ?? r'$';
  }
  return r'$';
}
