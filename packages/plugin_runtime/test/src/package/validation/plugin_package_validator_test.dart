import 'dart:typed_data';

import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/plugin_runtime.dart';
import 'package:test/test.dart';

void main() {
  group('PluginPackageValidator', () {
    test('reports a missing entry without invoking the adapter', () async {
      final package = _FakePluginPackageReader();
      final adapter = _FakeAdapter();

      final result = await const PluginPackageValidator().validate(
        package,
        _manifest(),
        adapter,
        wireProtocolVersion: 1,
      );

      expect(result.isValid, isFalse);
      expect(result.diagnostics.single.code, 'plugin.entry.missing');
      expect(result.diagnostics.single.relativePath, 'index.dart');
      expect(result.diagnostics.single.manifestPath.toString(), r'$.entry');
      expect(adapter.inspectCount, 0);
    });

    test('rejects an entry directory without invoking the adapter', () async {
      final package = _FakePluginPackageReader(
        entries: const {
          'index.dart': PluginPackageEntry(
            relativePath: 'index.dart',
            type: PluginPackageEntryType.directory,
            size: 0,
          ),
        },
      );
      final adapter = _FakeAdapter();

      final result = await const PluginPackageValidator().validate(
        package,
        _manifest(),
        adapter,
        wireProtocolVersion: 1,
      );

      expect(result.diagnostics.single.code, 'plugin.entry.not_file');
      expect(package.sameEntryChecks, isEmpty);
      expect(adapter.inspectCount, 0);
    });

    test('rejects an entry that resolves to the manifest file', () async {
      final package = _FakePluginPackageReader(entries: _entry, sameEntry: true);
      final adapter = _FakeAdapter();

      final result = await const PluginPackageValidator().validate(
        package,
        _manifest(),
        adapter,
        wireProtocolVersion: 1,
      );

      expect(result.diagnostics.single.code, 'plugin.entry.same_as_manifest');
      expect(adapter.inspectCount, 0);
    });

    test('delegates a distinct regular entry to the selected adapter', () async {
      final package = _FakePluginPackageReader(entries: _entry);
      final adapter = _FakeAdapter();

      final result = await const PluginPackageValidator().validate(
        package,
        _manifest(),
        adapter,
        wireProtocolVersion: 1,
      );

      expect(result.isValid, isTrue);
      expect(result.artifact?.adapterId, 'fixture');
      expect(result.artifact?.pluginId, 'dev.shinga.source');
      expect(result.artifact?.pluginVersion, '1.0.0');
      expect(result.artifact?.pluginApiVersion, 1);
      expect(result.artifact?.wireProtocolVersion, 1);
      expect(result.artifact?.entryPath, 'index.dart');
      expect(adapter.inspectCount, 1);
      expect(
        package.sameEntryChecks,
        [(PluginPackageFormat.manifestPath, 'index.dart')],
      );
    });

    test('maps adapter entry read failures to entry diagnostics', () async {
      final adapter = _FakeAdapter(
        diagnostic: const PackageDiagnostic.error(
          code: 'plugin.source.module_changed_during_read',
          message: 'Source changed.',
          relativePath: 'index.dart',
        ),
      );

      final result = await const PluginPackageValidator().validate(
        _FakePluginPackageReader(entries: _entry),
        _manifest(),
        adapter,
        wireProtocolVersion: 1,
      );

      expect(result.isValid, isFalse);
      expect(result.diagnostics.single.code, 'plugin.entry.changed_during_read');
      expect(result.diagnostics.single.manifestPath.toString(), r'$.entry');
    });

    test('rejects adapter output without a source candidate', () async {
      final result = await const PluginPackageValidator().validate(
        _FakePluginPackageReader(entries: _entry),
        _manifest(),
        _FakeAdapter(returnsNoCandidate: true),
        wireProtocolVersion: 1,
      );

      _expectInvalidAdapterOutput(result);
    });

    test('rejects a candidate missing the manifest entry source', () async {
      final result = await const PluginPackageValidator().validate(
        _FakePluginPackageReader(entries: _entry),
        _manifest(),
        _FakeAdapter(
          candidate: PluginArtifactCandidate(
            sourceBytes: {
              'other.dart': Uint8List.fromList([1]),
            },
          ),
        ),
        wireProtocolVersion: 1,
      );

      _expectInvalidAdapterOutput(result);
    });

    test('rejects empty, unsafe, and case-conflicting source maps', () async {
      final candidates = <PluginArtifactCandidate>[
        PluginArtifactCandidate(sourceBytes: const {}),
        PluginArtifactCandidate(
          sourceBytes: {
            'index.dart': Uint8List.fromList([1]),
            '../outside.dart': Uint8List.fromList([1]),
          },
        ),
        PluginArtifactCandidate(
          sourceBytes: {
            'index.dart': Uint8List.fromList([1]),
            'Value.dart': Uint8List.fromList([1]),
            'value.dart': Uint8List.fromList([1]),
          },
        ),
      ];

      for (final candidate in candidates) {
        final result = await const PluginPackageValidator().validate(
          _FakePluginPackageReader(entries: _entry),
          _manifest(),
          _FakeAdapter(candidate: candidate),
          wireProtocolVersion: 1,
        );

        _expectInvalidAdapterOutput(result);
      }
    });

    test('converts adapter exceptions to a safe deterministic diagnostic', () async {
      final result = await const PluginPackageValidator().validate(
        _FakePluginPackageReader(entries: _entry),
        _manifest(),
        _FakeAdapter(throwsDuringInspection: true),
        wireProtocolVersion: 1,
      );

      _expectInvalidAdapterOutput(result);
    });

    test('converts adapter identity getter failures to a safe diagnostic', () async {
      final result = await const PluginPackageValidator().validate(
        _FakePluginPackageReader(entries: _entry),
        _manifest(),
        _FakeAdapter(throwsReadingId: true),
        wireProtocolVersion: 1,
      );

      _expectInvalidAdapterOutput(result);
    });
  });
}

const _entry = {
  'index.dart': PluginPackageEntry(
    relativePath: 'index.dart',
    type: PluginPackageEntryType.file,
    size: 1,
  ),
};

PluginManifest _manifest() => PluginManifest(
  manifestVersion: ManifestFormatVersion.tryParse(1)!,
  id: PluginId.tryParse('dev.shinga.source')!,
  name: 'Source',
  version: PluginVersion.tryParse('1.0.0')!,
  pluginApiVersion: PluginApiVersion.tryParse(1)!,
  entry: PluginEntryPath.tryParse('index.dart')!,
  permissions: const PluginPermissions(),
  settings: const [],
);

final class _FakeAdapter implements PluginRuntimeAdapter {
  _FakeAdapter({
    this.diagnostic,
    PluginArtifactCandidate? candidate,
    bool returnsNoCandidate = false,
    this.throwsDuringInspection = false,
    this.throwsReadingId = false,
  }) : candidate = returnsNoCandidate
           ? null
           : candidate ??
                 PluginArtifactCandidate(
                   sourceBytes: {
                     'index.dart': Uint8List.fromList([1]),
                   },
                 );

  final PackageDiagnostic? diagnostic;
  final PluginArtifactCandidate? candidate;
  final bool throwsDuringInspection;
  final bool throwsReadingId;
  int inspectCount = 0;

  @override
  String get id {
    if (throwsReadingId) throw StateError('private adapter identity failure');
    return 'fixture';
  }

  @override
  Set<String> get entryExtensions => const {'.dart'};

  @override
  Object? createWorkerPayload(PluginExecutableArtifact artifact) => null;

  @override
  Future<PluginArtifactBuildResult> inspect(
    PluginPackageReader package,
    PluginManifest manifest,
  ) async {
    inspectCount += 1;
    if (throwsDuringInspection) throw StateError('private adapter failure');
    if (diagnostic case final diagnostic?) {
      return PluginArtifactBuildResult(diagnostics: [diagnostic], candidate: null);
    }
    return PluginArtifactBuildResult(
      diagnostics: const [],
      candidate: candidate,
    );
  }

  @override
  PluginWorkerEntrypoint get workerEntrypoint => _fixtureWorker;
}

PluginInvocationResponse _fixtureWorker(PluginWorkerContext context, Object? payload) {
  return PluginInvocationResponse.success(null);
}

final class _FakePluginPackageReader implements PluginPackageReader {
  _FakePluginPackageReader({this.entries = const {}, this.sameEntry = false});

  final Map<String, PluginPackageEntry> entries;
  final bool sameEntry;
  final List<(String, String)> sameEntryChecks = [];

  @override
  Future<bool> exists(String relativePath) async => entries.containsKey(relativePath);

  @override
  Future<List<int>> readBytes(String relativePath, {required int maxBytes}) async {
    return List<int>.filled(entries[relativePath]?.size ?? 0, 32);
  }

  @override
  Future<bool> refersToSameEntry(
    String firstRelativePath,
    String secondRelativePath,
  ) async {
    sameEntryChecks.add((firstRelativePath, secondRelativePath));
    return sameEntry;
  }

  @override
  Future<PluginPackageEntry?> stat(String relativePath) async => entries[relativePath];
}

void _expectInvalidAdapterOutput(PackageValidationResult result) {
  expect(result.isValid, isFalse);
  expect(result.artifact, isNull);
  expect(result.diagnostics.single.code, 'plugin.entry.adapter_output_invalid');
  expect(result.diagnostics.single.relativePath, 'index.dart');
  expect(result.diagnostics.single.manifestPath.toString(), r'$.entry');
}
