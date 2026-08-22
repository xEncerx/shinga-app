import 'package:plugin_runtime/plugin_runtime.dart';
import 'package:plugin_runtime/plugin_runtime_testing.dart';
import 'package:test/test.dart';

void main() {
  group('MemoryPluginPackageReader', () {
    test('reports file, directory, and missing entry metadata', () async {
      final reader = MemoryPluginPackageReader(
        files: const {
          'dist/index.js': [1, 2, 3],
        },
        directories: const {'dist'},
      );

      final file = await reader.stat('dist/index.js');
      final directory = await reader.stat('dist');

      expect(file?.relativePath, 'dist/index.js');
      expect(file?.type, PluginPackageEntryType.file);
      expect(file?.size, 3);
      expect(directory?.type, PluginPackageEntryType.directory);
      expect(directory?.size, 0);
      expect(await reader.stat('missing.js'), isNull);
      expect(await reader.exists('dist/index.js'), isTrue);
      expect(await reader.exists('missing.js'), isFalse);
    });

    test('reads a file at the exact byte limit without truncating it', () async {
      final source = <int>[1, 2, 3];
      final reader = MemoryPluginPackageReader(files: {'index.js': source});
      source[0] = 9;

      final bytes = await reader.readBytes('index.js', maxBytes: 3);
      bytes[1] = 9;
      final secondRead = await reader.readBytes('index.js', maxBytes: 3);

      expect(bytes, [1, 9, 3]);
      expect(secondRead, [1, 2, 3]);
    });

    test('rejects a file larger than the byte limit', () async {
      final reader = MemoryPluginPackageReader(
        files: const {
          'index.js': [1, 2, 3],
        },
      );

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
              .having((error) => error.relativePath, 'relativePath', 'index.js')
              .having((error) => error.maxBytes, 'maxBytes', 2),
        ),
      );
    });

    test('distinguishes missing paths and directories when reading', () async {
      final reader = MemoryPluginPackageReader(directories: const {'assets'});

      final missingRead = reader.readBytes('missing.js', maxBytes: 10);
      final directoryRead = reader.readBytes('assets', maxBytes: 10);

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
    });

    test('only treats an existing identical path as the same entry', () async {
      final reader = MemoryPluginPackageReader(
        files: const {
          'index.js': [1],
          'other.js': [1],
        },
      );

      final same = await reader.refersToSameEntry('index.js', 'index.js');
      final different = await reader.refersToSameEntry('index.js', 'other.js');
      final missing = await reader.refersToSameEntry('missing.js', 'missing.js');

      expect(same, isTrue);
      expect(different, isFalse);
      expect(missing, isFalse);
    });

    test('rejects unsafe package paths at construction and use', () async {
      const invalidPaths = [
        '',
        '/index.js',
        r'\index.js',
        r'dist\index.js',
        'dist/../index.js',
        'dist//index.js',
        'C:/index.js',
      ];

      for (final path in invalidPaths) {
        expect(
          () => MemoryPluginPackageReader(
            files: {
              path: const [1],
            },
          ),
          throwsA(
            isA<PluginPackageReadException>().having(
              (error) => error.failure,
              'failure',
              PluginPackageReadFailure.invalidPath,
            ),
          ),
          reason: path,
        );

        final reader = MemoryPluginPackageReader();
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
      }
    });

    test('rejects a negative byte limit', () async {
      final reader = MemoryPluginPackageReader(
        files: const {
          'index.js': [1],
        },
      );

      final read = reader.readBytes('index.js', maxBytes: -1);

      await expectLater(read, throwsArgumentError);
    });
  });
}
