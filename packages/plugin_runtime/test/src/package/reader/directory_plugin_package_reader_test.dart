import 'dart:async';
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

    test('rejects a physical file mutation during a stable read', () async {
      final file = File('${packageDirectory.path}${Platform.pathSeparator}index.js');
      await file.writeAsBytes([1, 2, 3]);

      final read = runZoned(
        () => reader.readBytes('index.js', maxBytes: 3),
        zoneValues: {
          #pluginRuntimeBeforeStableRead: (File activeFile) async {
            await activeFile.writeAsBytes([3, 2, 1], flush: true);
            await activeFile.setLastModified(DateTime.now().add(const Duration(seconds: 2)));
          },
        },
      );

      await expectLater(
        read,
        throwsA(
          isA<PluginPackageReadException>().having(
            (error) => error.failure,
            'failure',
            PluginPackageReadFailure.changedDuringRead,
          ),
        ),
      );
    });

    test('requires exact on-disk case for every portable path segment', () async {
      final directory = Directory('${packageDirectory.path}${Platform.pathSeparator}Source');
      await directory.create();
      await File('${directory.path}${Platform.pathSeparator}Value.dart').writeAsBytes([1]);

      expect(await reader.readBytes('Source/Value.dart', maxBytes: 1), [1]);
      await expectLater(
        reader.stat('source/Value.dart'),
        throwsA(
          isA<PluginPackageReadException>().having(
            (error) => error.failure,
            'failure',
            PluginPackageReadFailure.pathCaseMismatch,
          ),
        ),
      );
      await expectLater(
        reader.readBytes('Source/value.dart', maxBytes: 1),
        throwsA(
          isA<PluginPackageReadException>().having(
            (error) => error.failure,
            'failure',
            PluginPackageReadFailure.pathCaseMismatch,
          ),
        ),
      );
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

      await expectLater(
        reader.readBytes('assets', maxBytes: 10),
        throwsA(
          isA<PluginPackageReadException>().having(
            (error) => error.failure,
            'failure',
            PluginPackageReadFailure.notFile,
          ),
        ),
      );
      await expectLater(
        reader.readBytes('missing.js', maxBytes: 10),
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

    test('treats hard links as regular files when available', () async {
      final target = File('${packageDirectory.path}${Platform.pathSeparator}target.js');
      final hardLink = File('${packageDirectory.path}${Platform.pathSeparator}index.js');
      await target.writeAsBytes([1, 2, 3]);
      if (!await _createHardLink(target.path, hardLink.path)) {
        return;
      }

      expect(await reader.refersToSameEntry('target.js', 'index.js'), isTrue);
      expect(await reader.readBytes('index.js', maxBytes: 3), [1, 2, 3]);
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

    test('rejects a symbolic link in a nested parent path', () async {
      final target = await Directory.systemTemp.createTemp('plugin_reader_target_');
      addTearDown(() async {
        if (target.existsSync()) {
          await target.delete(recursive: true);
        }
      });
      await File('${target.path}${Platform.pathSeparator}index.js').writeAsBytes([1]);
      final link = Link('${packageDirectory.path}${Platform.pathSeparator}nested');
      try {
        await link.create(target.path);
      } on FileSystemException {
        return;
      }

      await expectLater(
        reader.readBytes('nested/index.js', maxBytes: 1),
        throwsA(
          isA<PluginPackageReadException>().having(
            (error) => error.failure,
            'failure',
            anyOf(
              PluginPackageReadFailure.symbolicLink,
              PluginPackageReadFailure.outsidePackage,
            ),
          ),
        ),
      );
    });

    test(
      'rejects a Windows junction in a nested parent path',
      () async {
        final target = await Directory.systemTemp.createTemp('plugin_reader_target_');
        addTearDown(() async {
          if (target.existsSync()) {
            await target.delete(recursive: true);
          }
        });
        await File('${target.path}${Platform.pathSeparator}index.js').writeAsBytes([1]);
        final junctionPath = '${packageDirectory.path}${Platform.pathSeparator}nested';
        final result = await Process.run('cmd', ['/c', 'mklink', '/J', junctionPath, target.path]);
        if (result.exitCode != 0) {
          return;
        }

        await expectLater(
          reader.readBytes('nested/index.js', maxBytes: 1),
          throwsA(isA<PluginPackageReadException>()),
        );
      },
      skip: !Platform.isWindows ? 'Windows junction behavior is platform-specific.' : false,
    );

    test('rejects unsafe package paths for stat and reads', () async {
      const invalidPaths = [
        '',
        '/index.js',
        r'\index.js',
        r'dist\index.js',
        '../index.js',
        'dist/./index.js',
        'C:/index.js',
        'CON.js',
        'dist/AUX.js',
        'index?.js',
        'index.js.',
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

Future<bool> _createHardLink(String target, String link) async {
  final ProcessResult result;
  if (Platform.isWindows) {
    result = await Process.run('cmd', ['/c', 'mklink', '/H', link, target]);
  } else {
    result = await Process.run('ln', [target, link]);
  }
  return result.exitCode == 0;
}
