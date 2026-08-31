import 'dart:convert';

import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/plugin_runtime.dart';
import 'package:plugin_runtime/plugin_runtime_testing.dart';
import 'package:test/test.dart';

void main() {
  group('PluginManifestLoader', () {
    late PluginManifestParser parser;

    setUp(() {
      parser = PluginManifestParser();
    });

    test('reports a missing manifest', () async {
      final loader = PluginManifestLoader(parser: parser);
      final package = MemoryPluginPackageReader();

      final result = await loader.load(package);

      expect(result.manifest, isNull);
      expect(result.hasErrors, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.diagnostics.single.code, 'plugin.package.manifest_missing');
      expect(
        (result.diagnostics.single as PackageDiagnostic).relativePath,
        PluginPackageFormat.manifestPath,
      );
    });

    test('rejects a manifest whose stat size exceeds the bound', () async {
      final loader = PluginManifestLoader(parser: parser, maxManifestBytes: 2);
      final package = MemoryPluginPackageReader(
        files: const {
          PluginPackageFormat.manifestPath: [1, 2, 3],
        },
      );

      final result = await loader.load(package);

      expect(result.manifest, isNull);
      expect(result.diagnostics.single.code, 'plugin.package.manifest_too_large');
      expect(result.diagnostics.single.message, contains('2 bytes'));
    });

    test('rejects malformed UTF-8 before parsing', () async {
      final loader = PluginManifestLoader(parser: parser);
      final package = MemoryPluginPackageReader(
        files: const {
          PluginPackageFormat.manifestPath: [0xC3, 0x28],
        },
      );

      final result = await loader.load(package);

      expect(result.manifest, isNull);
      expect(result.diagnostics.single.code, 'plugin.package.manifest_invalid_utf8');
    });

    test('forwards parser diagnostics for invalid manifest JSON', () async {
      final loader = PluginManifestLoader(parser: parser);
      final package = MemoryPluginPackageReader(
        files: {
          PluginPackageFormat.manifestPath: utf8.encode('{"manifestVersion": 1'),
        },
      );

      final result = await loader.load(package);

      expect(result.manifest, isNull);
      expect(result.diagnostics.single, isA<ManifestDiagnostic>());
      expect(result.diagnostics.single.code, 'manifest.json.invalid');
      expect((result.diagnostics.single as ManifestDiagnostic).path.toString(), r'$');
    });

    test('returns a parsed manifest and preserves parser warnings', () async {
      final source = jsonEncode({..._manifestJson(), 'futureField': true});
      final loader = PluginManifestLoader(parser: parser);
      final package = MemoryPluginPackageReader(
        files: {PluginPackageFormat.manifestPath: utf8.encode(source)},
      );

      final result = await loader.load(package);

      expect(result.isSuccess, isTrue);
      expect(result.manifest?.id.value, 'dev.shinga.source');
      expect(result.diagnostics.single.severity, DiagnosticSeverity.warning);
      expect(result.diagnostics.single.code, 'manifest.field.unknown');
    });

    test('rejects a manifest that changes while being read', () async {
      final loader = PluginManifestLoader(parser: parser);
      const package = _FailingManifestReader(
        PluginPackageReadFailure.changedDuringRead,
      );

      final result = await loader.load(package);

      expect(result.manifest, isNull);
      expect(result.diagnostics.single.code, 'plugin.package.manifest_unreadable');
    });

    test('rejects a manifest that cannot be read', () async {
      final loader = PluginManifestLoader(parser: parser);
      const package = _FailingManifestReader(PluginPackageReadFailure.io);

      final result = await loader.load(package);

      expect(result.manifest, isNull);
      expect(result.diagnostics.single.code, 'plugin.package.manifest_unreadable');
    });
  });
}

final class _FailingManifestReader implements PluginPackageReader {
  const _FailingManifestReader(this.failure);

  final PluginPackageReadFailure failure;

  @override
  Future<bool> exists(String relativePath) async => true;

  @override
  Future<List<int>> readBytes(String relativePath, {required int maxBytes}) {
    throw PluginPackageReadException(
      failure: failure,
      relativePath: PluginPackageFormat.manifestPath,
    );
  }

  @override
  Future<bool> refersToSameEntry(String firstRelativePath, String secondRelativePath) async {
    return firstRelativePath == secondRelativePath;
  }

  @override
  Future<PluginPackageEntry?> stat(String relativePath) async {
    return const PluginPackageEntry(
      relativePath: PluginPackageFormat.manifestPath,
      type: PluginPackageEntryType.file,
      size: 1,
    );
  }
}

Map<String, Object?> _manifestJson() => <String, Object?>{
  'manifestVersion': 1,
  'id': 'dev.shinga.source',
  'name': 'Source',
  'version': '1.0.0',
  'pluginApiVersion': 1,
  'entry': 'index.dart',
};
