import 'dart:convert';
import 'dart:io';

import 'package:plugin_inspect/plugin_inspect.dart';
import 'package:test/test.dart';

void main() {
  group('runPluginInspect', () {
    late Directory packageDirectory;

    setUp(() async {
      packageDirectory = await Directory.systemTemp.createTemp('plugin_inspect_test_');
    });

    tearDown(() async {
      if (packageDirectory.existsSync()) {
        await packageDirectory.delete(recursive: true);
      }
    });

    test('prints a valid package summary and exits successfully', () async {
      final manifest = File(
        '${packageDirectory.path}${Platform.pathSeparator}manifest.json',
      );
      final entry = File(
        '${packageDirectory.path}${Platform.pathSeparator}index.dart',
      );
      await manifest.writeAsString(jsonEncode(_manifestJson()));
      await entry.writeAsString('Object? run(Object? value) => value;');
      final output = StringBuffer();
      final errorOutput = StringBuffer();

      final exitCode = await runPluginInspect(
        [packageDirectory.path],
        output: output,
        errorOutput: errorOutput,
      );

      expect(exitCode, 0);
      expect(
        output.toString(),
        [
          'Plugin: dev.shinga.source',
          'Version: 1.2.3',
          'Plugin API: 1',
          'Entry: index.dart',
          'Settings: 0',
          'Network hosts: api.example.com',
          '',
          'Package is structurally valid.',
          '',
        ].join('\n'),
      );
      expect(errorOutput.toString(), isEmpty);
    });

    test('prints invalid-package diagnostics and exits with failure', () async {
      final manifest = File(
        '${packageDirectory.path}${Platform.pathSeparator}manifest.json',
      );
      await manifest.writeAsString(jsonEncode(_manifestJson()));
      final output = StringBuffer();
      final errorOutput = StringBuffer();

      final exitCode = await runPluginInspect(
        [packageDirectory.path],
        output: output,
        errorOutput: errorOutput,
      );

      expect(exitCode, 1);
      expect(output.toString(), isEmpty);
      expect(errorOutput.toString(), contains(r'ERROR $.entry'));
      expect(errorOutput.toString(), contains('plugin.entry.missing'));
      expect(errorOutput.toString(), contains('Entry file "index.dart" does not exist.'));
    });

    test(
      'rejects a manifest entry whose case differs from the Windows file',
      () async {
        await File(
          '${packageDirectory.path}${Platform.pathSeparator}manifest.json',
        ).writeAsString(jsonEncode(_manifestJson()));
        await File(
          '${packageDirectory.path}${Platform.pathSeparator}Index.dart',
        ).writeAsString('Object? run(Object? value) => value;');
        final output = StringBuffer();
        final errorOutput = StringBuffer();

        final exitCode = await runPluginInspect(
          [packageDirectory.path],
          output: output,
          errorOutput: errorOutput,
        );

        expect(exitCode, 1);
        expect(output.toString(), isEmpty);
        expect(errorOutput.toString(), contains('plugin.entry.path_case_mismatch'));
      },
      skip: !Platform.isWindows ? 'Windows path aliases are platform-specific.' : false,
    );

    test(
      'rejects an import whose case differs from the Windows file',
      () async {
        await File(
          '${packageDirectory.path}${Platform.pathSeparator}manifest.json',
        ).writeAsString(jsonEncode(_manifestJson()));
        await File(
          '${packageDirectory.path}${Platform.pathSeparator}index.dart',
        ).writeAsString("import 'Source/Value.dart'; Object? run(Object? value) => value;");
        final sourceDirectory = Directory(
          '${packageDirectory.path}${Platform.pathSeparator}Source',
        );
        await sourceDirectory.create();
        await File(
          '${sourceDirectory.path}${Platform.pathSeparator}value.dart',
        ).writeAsString('const value = 1;');
        final output = StringBuffer();
        final errorOutput = StringBuffer();

        final exitCode = await runPluginInspect(
          [packageDirectory.path],
          output: output,
          errorOutput: errorOutput,
        );

        expect(exitCode, 1);
        expect(output.toString(), isEmpty);
        expect(
          errorOutput.toString(),
          contains('plugin.source.module_path_case_mismatch'),
        );
      },
      skip: !Platform.isWindows ? 'Windows path aliases are platform-specific.' : false,
    );

    test('prints usage and exits with argument error for invalid arguments', () async {
      final output = StringBuffer();
      final errorOutput = StringBuffer();

      final exitCode = await runPluginInspect(
        const [],
        output: output,
        errorOutput: errorOutput,
      );

      expect(exitCode, 2);
      expect(output.toString(), isEmpty);
      expect(
        errorOutput.toString(),
        contains('Usage: dart run tools/plugin_inspect/bin/plugin_inspect.dart'),
      );
    });

    test('reports a nonexistent directory and exits with argument error', () async {
      await packageDirectory.delete();
      final output = StringBuffer();
      final errorOutput = StringBuffer();

      final exitCode = await runPluginInspect(
        [packageDirectory.path],
        output: output,
        errorOutput: errorOutput,
      );

      expect(exitCode, 2);
      expect(output.toString(), isEmpty);
      expect(
        errorOutput.toString(),
        contains('Plugin directory does not exist: ${packageDirectory.path}'),
      );
    });
  });
}

Map<String, Object?> _manifestJson() => <String, Object?>{
  'manifestVersion': 1,
  'id': 'dev.shinga.source',
  'name': 'Source',
  'version': '1.2.3',
  'pluginApiVersion': 1,
  'entry': 'index.dart',
  'permissions': {
    'network': {
      'hosts': ['api.example.com'],
    },
  },
};
