import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/plugin_runtime.dart';
import 'package:test/test.dart';

void main() {
  group('PluginPackageValidator', () {
    test('reports a missing entry', () async {
      final package = _FakePluginPackageReader();
      const validator = PluginPackageValidator();

      final result = await validator.validate(package, _manifest());

      expect(result.isValid, isFalse);
      expect(result.diagnostics.single.code, 'plugin.entry.missing');
      expect(result.diagnostics.single.relativePath, 'index.dart');
      expect(result.diagnostics.single.manifestPath.toString(), r'$.entry');
      expect(package.readPaths, isEmpty);
    });

    test('rejects an entry directory without reading it', () async {
      final package = _FakePluginPackageReader(
        entries: const {
          'index.dart': PluginPackageEntry(
            relativePath: 'index.dart',
            type: PluginPackageEntryType.directory,
            size: 0,
          ),
        },
      );
      const validator = PluginPackageValidator();

      final result = await validator.validate(package, _manifest());

      expect(result.diagnostics.single.code, 'plugin.entry.not_file');
      expect(package.sameEntryChecks, isEmpty);
      expect(package.readPaths, isEmpty);
    });

    test('reports an oversized entry without reading its bytes', () async {
      final package = _FakePluginPackageReader(
        entries: const {
          'index.dart': PluginPackageEntry(
            relativePath: 'index.dart',
            type: PluginPackageEntryType.file,
            size: 4,
          ),
        },
      );
      const validator = PluginPackageValidator(maxEntryBytes: 3);

      final result = await validator.validate(package, _manifest());

      expect(result.diagnostics.single.code, 'plugin.entry.too_large');
      expect(result.diagnostics.single.message, contains('3 bytes'));
      expect(package.readPaths, isEmpty);
      expect(
        package.sameEntryChecks,
        [(PluginPackageFormat.manifestPath, 'index.dart')],
      );
    });

    test('rejects an entry that resolves to the manifest file', () async {
      final package = _FakePluginPackageReader(
        entries: const {
          'index.dart': PluginPackageEntry(
            relativePath: 'index.dart',
            type: PluginPackageEntryType.file,
            size: 1,
          ),
        },
        sameEntry: true,
      );
      const validator = PluginPackageValidator(maxEntryBytes: 1);

      final result = await validator.validate(package, _manifest());

      expect(result.diagnostics.single.code, 'plugin.entry.same_as_manifest');
      expect(package.readPaths, isEmpty);
      expect(package.readLimits, isEmpty);
    });

    test('accepts a distinct readable entry at the exact size bound', () async {
      final package = _FakePluginPackageReader(
        entries: const {
          'index.dart': PluginPackageEntry(
            relativePath: 'index.dart',
            type: PluginPackageEntryType.file,
            size: 1,
          ),
        },
      );
      const validator = PluginPackageValidator(maxEntryBytes: 1);

      final result = await validator.validate(package, _manifest());

      expect(result.isValid, isTrue);
      expect(result.diagnostics, isEmpty);
      expect(package.readPaths, ['index.dart']);
      expect(package.readLimits, [1]);
    });

    test('rejects an entry that changes while being read', () async {
      final package = _FakePluginPackageReader(
        entries: const {
          'index.dart': PluginPackageEntry(
            relativePath: 'index.dart',
            type: PluginPackageEntryType.file,
            size: 1,
          ),
        },
        readFailure: PluginPackageReadFailure.changedDuringRead,
      );
      const validator = PluginPackageValidator(maxEntryBytes: 1);

      final result = await validator.validate(package, _manifest());

      expect(result.isValid, isFalse);
      expect(result.diagnostics.single.code, 'plugin.entry.changed_during_read');
    });

    test('rejects an entry that cannot be read', () async {
      final package = _FakePluginPackageReader(
        entries: const {
          'index.dart': PluginPackageEntry(
            relativePath: 'index.dart',
            type: PluginPackageEntryType.file,
            size: 1,
          ),
        },
        readFailure: PluginPackageReadFailure.io,
      );
      const validator = PluginPackageValidator(maxEntryBytes: 1);

      final result = await validator.validate(package, _manifest());

      expect(result.isValid, isFalse);
      expect(result.diagnostics.single.code, 'plugin.entry.unreadable');
    });
  });
}

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

final class _FakePluginPackageReader implements PluginPackageReader {
  _FakePluginPackageReader({
    this.entries = const {},
    this.sameEntry = false,
    this.readFailure,
  });

  final Map<String, PluginPackageEntry> entries;
  final bool sameEntry;
  final PluginPackageReadFailure? readFailure;
  final List<String> readPaths = [];
  final List<int> readLimits = [];
  final List<(String, String)> sameEntryChecks = [];

  @override
  Future<bool> exists(String relativePath) async => entries.containsKey(relativePath);

  @override
  Future<List<int>> readBytes(
    String relativePath, {
    required int maxBytes,
  }) async {
    readPaths.add(relativePath);
    readLimits.add(maxBytes);
    if (readFailure case final failure?) {
      throw PluginPackageReadException(
        failure: failure,
        relativePath: relativePath,
      );
    }
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
