import 'dart:io';

import 'package:plugin_runtime/plugin_runtime.dart';
import 'package:test/test.dart';

void main() {
  group('DirectoryPluginPackageReader', () {
    late Directory packageDirectory;
    late DirectoryPluginPackageReader reader;

    setUp(() async {
      packageDirectory = await Directory.systemTemp.createTemp('plugin_reader_test_');
      reader = DirectoryPluginPackageReader(packageDirectory);
    });

    tearDown(() async {
      if (packageDirectory.existsSync()) {
        await packageDirectory.delete(recursive: true);
      }
    });

    test('reports file, directory, and missing entry metadata', () async {
      final directory = Directory('${packageDirectory.path}${Platform.pathSeparator}dist');
      await directory.create();
      final file = File('${directory.path}${Platform.pathSeparator}index.js');
      await file.writeAsBytes([1, 2, 3]);

      final fileEntry = await reader.stat('dist/index.js');
      final directoryEntry = await reader.stat('dist');

      expect(fileEntry?.relativePath, 'dist/index.js');
      expect(fileEntry?.type, PluginPackageEntryType.file);
      expect(fileEntry?.size, 3);
      expect(directoryEntry?.type, PluginPackageEntryType.directory);
      expect(directoryEntry?.size, 0);
      expect(await reader.stat('missing.js'), isNull);
      expect(await reader.exists('dist/index.js'), isTrue);
      expect(await reader.exists('missing.js'), isFalse);
    });

    test('reads a file at the exact byte limit', () async {
      final file = File('${packageDirectory.path}${Platform.pathSeparator}index.js');
      await file.writeAsBytes([1, 2, 3]);

      final bytes = await reader.readBytes('index.js', maxBytes: 3);

      expect(bytes, [1, 2, 3]);
    });

    test('rejects a file larger than the byte limit', () async {
      final file = File('${packageDirectory.path}${Platform.pathSeparator}index.js');
      await file.writeAsBytes([1, 2, 3]);

      final read = reader.readBytes('index.js', maxBytes: 2);

      await expectLater(
        read,
        throwsA(
          isA<PluginPackageReadException>()
              .having(
                (error) => error.failure,
                'failure',
                PluginPackageReadFailure.tooLarge,
              )
              .having((error) => error.maxBytes, 'maxBytes', 2),
        ),
      );
    });

    test('rejects directories and reports missing files when reading', () async {
      await Directory(
        '${packageDirectory.path}${Platform.pathSeparator}assets',
      ).create();

      final directoryRead = reader.readBytes('assets', maxBytes: 10);
      final missingRead = reader.readBytes('missing.js', maxBytes: 10);

      await expectLater(
        directoryRead,
        throwsA(
          isA<PluginPackageReadException>().having(
            (error) => error.failure,
            'failure',
            PluginPackageReadFailure.notFile,
          ),
        ),
      );
      await expectLater(
        missingRead,
        throwsA(
          isA<PluginPackageReadException>().having(
            (error) => error.failure,
            'failure',
            PluginPackageReadFailure.notFound,
          ),
        ),
      );
    });

    test('compares physical entries', () async {
      final first = File('${packageDirectory.path}${Platform.pathSeparator}first.js');
      final second = File('${packageDirectory.path}${Platform.pathSeparator}second.js');
      await first.writeAsBytes([1]);
      await second.writeAsBytes([1]);

      final same = await reader.refersToSameEntry('first.js', 'first.js');
      final different = await reader.refersToSameEntry('first.js', 'second.js');

      expect(same, isTrue);
      expect(different, isFalse);
    });

    test('rejects a symbolic link entry when links are available', () async {
      final target = File('${packageDirectory.path}${Platform.pathSeparator}target.js');
      final link = Link('${packageDirectory.path}${Platform.pathSeparator}index.js');
      await target.writeAsBytes([1]);
      try {
        await link.create(target.path);
      } on FileSystemException {
        return;
      }

      final entry = await reader.stat('index.js');
      final read = reader.readBytes('index.js', maxBytes: 1);

      expect(entry?.type, PluginPackageEntryType.symbolicLink);
      await expectLater(
        read,
        throwsA(
          isA<PluginPackageReadException>().having(
            (error) => error.failure,
            'failure',
            PluginPackageReadFailure.symbolicLink,
          ),
        ),
      );
    });

    test('rejects unsafe package paths for stat and reads', () async {
      const invalidPaths = [
        '',
        '/index.js',
        r'\index.js',
        r'dist\index.js',
        '../index.js',
        'dist/./index.js',
        'C:/index.js',
      ];

      for (final path in invalidPaths) {
        await expectLater(
          reader.stat(path),
          throwsA(
            isA<PluginPackageReadException>().having(
              (error) => error.failure,
              'failure',
              PluginPackageReadFailure.invalidPath,
            ),
          ),
          reason: path,
        );
        await expectLater(
          reader.readBytes(path, maxBytes: 10),
          throwsA(
            isA<PluginPackageReadException>().having(
              (error) => error.failure,
              'failure',
              PluginPackageReadFailure.invalidPath,
            ),
          ),
          reason: path,
        );
      }
    });

    test('rejects a negative byte limit', () async {
      final file = File('${packageDirectory.path}${Platform.pathSeparator}index.js');
      await file.writeAsBytes([1]);

      final read = reader.readBytes('index.js', maxBytes: -1);

      await expectLater(read, throwsArgumentError);
    });
  });
}
