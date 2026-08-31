import 'dart:convert';
import 'dart:typed_data';

import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/plugin_runtime.dart';
import 'package:plugin_runtime/plugin_runtime_testing.dart';
import 'package:test/test.dart';

void main() {
  group('PluginExecutableArtifactBuilder', () {
    test('closes local imports from exact bytes into immutable source maps', () async {
      final reader = _CountingReader({
        'index.dart': utf8.encode("import 'src/value.dart'; Object? run(Object? _) => value;"),
        'src/value.dart': utf8.encode('const value = 42;'),
      });

      final result = await const PluginExecutableArtifactBuilder().build(reader, _manifest());

      expect(result.isValid, isTrue);
      final artifact = result.artifact!;
      expect(artifact.entryModuleId, 'package:dev.shinga.fixture/index.dart');
      expect(artifact.sources, {
        'package:dev.shinga.fixture/index.dart':
            "import 'src/value.dart'; Object? run(Object? _) => value;",
        'package:dev.shinga.fixture/src/value.dart': 'const value = 42;',
      });
      expect(reader.readCounts.values, everyElement(1));
      expect(() => artifact.sources['late'] = 'source', throwsUnsupportedError);
      final copiedBytes = artifact.copySourceBytes();
      expect(copiedBytes.keys, artifact.sources.keys);
      expect(
        copiedBytes['package:dev.shinga.fixture/src/value.dart'],
        utf8.encode('const value = 42;'),
      );
      copiedBytes['package:dev.shinga.fixture/src/value.dart']![0] = 0;
      expect(
        artifact.copySourceBytes()['package:dev.shinga.fixture/src/value.dart'],
        utf8.encode('const value = 42;'),
      );
    });

    test('accepts exact per-module and aggregate source ceilings', () async {
      final exactModule = utf8.encode('/*${'a' * (256 * 1024 - 4)}*/');
      final exactAggregateEntry = _padded("import 'a.dart'; import 'b.dart';", 50);
      final reader = MemoryPluginPackageReader(
        files: {
          'index.dart': exactAggregateEntry,
          'a.dart': _padded('const a = 1;', 49),
          'b.dart': utf8.encode(' '),
        },
      );

      final moduleResult = await const PluginExecutableArtifactBuilder().build(
        MemoryPluginPackageReader(files: {'index.dart': exactModule}),
        _manifest(),
      );
      final aggregateResult = await const PluginExecutableArtifactBuilder(
        maxModuleBytes: 50,
        maxAggregateBytes: 100,
      ).build(reader, _manifest());

      expect(moduleResult.isValid, isTrue);
      expect(aggregateResult.isValid, isTrue);
    });

    test('rejects aggregate source one byte beyond its inclusive ceiling', () async {
      final result =
          await const PluginExecutableArtifactBuilder(
            maxModuleBytes: 50,
            maxAggregateBytes: 100,
          ).build(
            MemoryPluginPackageReader(
              files: {
                'index.dart': _padded("import 'a.dart'; import 'b.dart';", 50),
                'a.dart': _padded('const a = 1;', 49),
                'b.dart': utf8.encode('  '),
              },
            ),
            _manifest(),
          );

      expect(result.artifact, isNull);
      expect(result.diagnostics.single.code, 'plugin.source.aggregate_too_large');
    });

    test('rejects a module one byte beyond its inclusive ceiling', () async {
      final result = await const PluginExecutableArtifactBuilder().build(
        MemoryPluginPackageReader(
          files: {
            'index.dart': utf8.encode('/*${'a' * (256 * 1024 - 3)}*/'),
          },
        ),
        _manifest(),
      );

      expect(result.artifact, isNull);
      expect(result.diagnostics.single.code, 'plugin.source.module_too_large');
    });

    for (final testCase in <(String, List<int>)>[
      ('plugin.source.bom_forbidden', <int>[0xef, 0xbb, 0xbf, ...utf8.encode('void run() {}')]),
      ('plugin.source.nul_forbidden', <int>[...utf8.encode('void run() {}'), 0]),
      ('plugin.source.invalid_utf8', <int>[0xc3]),
      ('plugin.source.invalid_utf8', <int>[0xf0, 0x9f, 0x92]),
    ]) {
      test('rejects ${testCase.$1}', () async {
        final result = await const PluginExecutableArtifactBuilder().build(
          MemoryPluginPackageReader(files: {'index.dart': testCase.$2}),
          _manifest(),
        );

        expect(result.artifact, isNull);
        expect(result.diagnostics.single.code, testCase.$1);
      });
    }

    test('fails closed for forbidden, missing, URL, absolute, and traversal imports', () async {
      final imports = <String>[
        "import 'dart:io';",
        "import 'dart:isolate';",
        "import 'dart:developer';",
        "import 'package:other/value.dart';",
        "import 'file:///tmp/value.dart';",
        "import 'https://example.com/value.dart';",
        "import '../value.dart';",
        "import 'value.dart' deferred as value;",
        "import 'value.dart' if (dart.library.io) 'io.dart';",
        "part 'value.dart';",
      ];
      for (final importSource in imports) {
        final result = await const PluginExecutableArtifactBuilder().build(
          MemoryPluginPackageReader(
            files: {'index.dart': utf8.encode('$importSource Object? run(Object? _) => null;')},
          ),
          _manifest(),
        );

        expect(result.artifact, isNull, reason: importSource);
        expect(result.diagnostics.single.code, 'plugin.source.import_forbidden');
      }

      final missing = await const PluginExecutableArtifactBuilder().build(
        MemoryPluginPackageReader(
          files: {
            'index.dart': utf8.encode("import 'missing.dart'; Object? run(Object? _) => null;"),
          },
        ),
        _manifest(),
      );
      expect(missing.diagnostics.single.code, 'plugin.source.module_missing');
    });

    test('allows only the approved ambient-I/O-free SDK imports', () async {
      final source = PluginExecutableArtifactBuilder.allowedDartLibraries
          .map((library) => "import '$library';")
          .join();

      final result = await const PluginExecutableArtifactBuilder().build(
        MemoryPluginPackageReader(
          files: {'index.dart': utf8.encode('$source Object? run(Object? _) => null;')},
        ),
        _manifest(),
      );

      expect(result.isValid, isTrue);
    });

    test('rejects module paths that collide under portable case folding', () async {
      final result = await const PluginExecutableArtifactBuilder().build(
        MemoryPluginPackageReader(
          files: {
            'index.dart': utf8.encode(
              "import 'Value.dart'; import 'value.dart'; Object? run(Object? _) => null;",
            ),
            'Value.dart': utf8.encode('const upper = 1;'),
            'value.dart': utf8.encode('const lower = 2;'),
          },
        ),
        _manifest(),
      );

      expect(result.artifact, isNull);
      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        contains('plugin.source.module_case_collision'),
      );
    });

    test('rejects distinct module IDs that identify one physical file', () async {
      final result = await const PluginExecutableArtifactBuilder().build(
        _AliasingReader({
          'index.dart': utf8.encode(
            "import 'first.dart'; import 'second.dart'; Object? run(Object? _) => null;",
          ),
          'first.dart': utf8.encode('const first = 1;'),
          'second.dart': utf8.encode('const second = 2;'),
        }),
        _manifest(),
      );

      expect(result.artifact, isNull);
      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        contains('plugin.source.module_alias_forbidden'),
      );
    });
  });
}

Uint8List _padded(String source, int length) {
  final paddingLength = length - utf8.encode(source).length - 4;
  return Uint8List.fromList(utf8.encode('$source/*${'a' * paddingLength}*/'));
}

PluginManifest _manifest() => PluginManifest(
  manifestVersion: ManifestFormatVersion.tryParse(1)!,
  id: PluginId.tryParse('dev.shinga.fixture')!,
  name: 'Fixture',
  version: PluginVersion.tryParse('1.0.0')!,
  pluginApiVersion: PluginApiVersion.tryParse(1)!,
  entry: PluginEntryPath.tryParse('index.dart')!,
  permissions: const PluginPermissions(),
  settings: const [],
);

final class _CountingReader implements PluginPackageReader {
  _CountingReader(Map<String, List<int>> files)
    : _delegate = MemoryPluginPackageReader(files: files);

  final MemoryPluginPackageReader _delegate;
  final Map<String, int> readCounts = {};

  @override
  Future<bool> exists(String relativePath) => _delegate.exists(relativePath);

  @override
  Future<List<int>> readBytes(String relativePath, {required int maxBytes}) {
    readCounts.update(relativePath, (count) => count + 1, ifAbsent: () => 1);
    return _delegate.readBytes(relativePath, maxBytes: maxBytes);
  }

  @override
  Future<bool> refersToSameEntry(String firstRelativePath, String secondRelativePath) {
    return _delegate.refersToSameEntry(firstRelativePath, secondRelativePath);
  }

  @override
  Future<PluginPackageEntry?> stat(String relativePath) => _delegate.stat(relativePath);
}

final class _AliasingReader implements PluginPackageReader {
  _AliasingReader(Map<String, List<int>> files)
    : _delegate = MemoryPluginPackageReader(files: files);

  final MemoryPluginPackageReader _delegate;

  @override
  Future<bool> exists(String relativePath) => _delegate.exists(relativePath);

  @override
  Future<List<int>> readBytes(String relativePath, {required int maxBytes}) {
    return _delegate.readBytes(relativePath, maxBytes: maxBytes);
  }

  @override
  Future<bool> refersToSameEntry(
    String firstRelativePath,
    String secondRelativePath,
  ) async {
    return {firstRelativePath, secondRelativePath}.containsAll({
      'first.dart',
      'second.dart',
    });
  }

  @override
  Future<PluginPackageEntry?> stat(String relativePath) => _delegate.stat(relativePath);
}
