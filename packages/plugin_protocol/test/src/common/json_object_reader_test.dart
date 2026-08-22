import 'package:plugin_protocol/src/common/common.dart';
import 'package:test/test.dart';

void main() {
  group('JsonObjectReader.requiredString', () {
    test('reads a string', () {
      final diagnostics = DiagnosticCollector();
      final reader = _reader({'name': 'MangaFoo'}, diagnostics);

      expect(reader.requiredString('name'), 'MangaFoo');
      expect(diagnostics.diagnostics, isEmpty);
    });

    test('reports a missing field', () {
      final diagnostics = DiagnosticCollector();
      final reader = _reader({}, diagnostics);

      expect(reader.requiredString('name'), isNull);
      _expectDiagnostic(
        diagnostics,
        code: 'manifest.field.missing',
        path: r'$.name',
        message: 'Required field is missing.',
      );
    });

    test('reports a type mismatch', () {
      final diagnostics = DiagnosticCollector();
      final reader = _reader({'name': 1}, diagnostics);

      expect(reader.requiredString('name'), isNull);
      _expectDiagnostic(
        diagnostics,
        code: 'manifest.field.type_mismatch',
        path: r'$.name',
        message: 'Expected string, got integer.',
      );
    });
  });

  group('JsonObjectReader.optionalString', () {
    test('reads a string and ignores an absent field', () {
      final diagnostics = DiagnosticCollector();
      final reader = _reader({'entry': 'index.js'}, diagnostics);

      expect(reader.optionalString('entry'), 'index.js');
      expect(reader.optionalString('description'), isNull);
      expect(diagnostics.diagnostics, isEmpty);
    });

    test('reports a type mismatch', () {
      final diagnostics = DiagnosticCollector();
      final reader = _reader({'entry': false}, diagnostics);

      expect(reader.optionalString('entry'), isNull);
      _expectDiagnostic(
        diagnostics,
        code: 'manifest.field.type_mismatch',
        path: r'$.entry',
        message: 'Expected string, got boolean.',
      );
    });
  });

  group('JsonObjectReader.requiredInt', () {
    test('reads an integer', () {
      final diagnostics = DiagnosticCollector();
      final reader = _reader({'pluginApiVersion': 1}, diagnostics);

      expect(reader.requiredInt('pluginApiVersion'), 1);
      expect(diagnostics.diagnostics, isEmpty);
    });

    test('reports missing and non-integer values', () {
      final missingDiagnostics = DiagnosticCollector();
      final mismatchedDiagnostics = DiagnosticCollector();

      expect(_reader({}, missingDiagnostics).requiredInt('pluginApiVersion'), isNull);
      expect(
        _reader({'pluginApiVersion': 1.5}, mismatchedDiagnostics).requiredInt('pluginApiVersion'),
        isNull,
      );
      expect(missingDiagnostics.diagnostics.single.code, 'manifest.field.missing');
      _expectDiagnostic(
        mismatchedDiagnostics,
        code: 'manifest.field.type_mismatch',
        path: r'$.pluginApiVersion',
        message: 'Expected integer, got number.',
      );
    });
  });

  group('JsonObjectReader.optionalBool', () {
    test('reads a boolean and ignores an absent field', () {
      final diagnostics = DiagnosticCollector();
      final reader = _reader({'required': true}, diagnostics);

      expect(reader.optionalBool('required'), isTrue);
      expect(reader.optionalBool('hidden'), isNull);
      expect(diagnostics.diagnostics, isEmpty);
    });

    test('reports a type mismatch', () {
      final diagnostics = DiagnosticCollector();
      final reader = _reader({'required': 'true'}, diagnostics);

      expect(reader.optionalBool('required'), isNull);
      _expectDiagnostic(
        diagnostics,
        code: 'manifest.field.type_mismatch',
        path: r'$.required',
        message: 'Expected boolean, got string.',
      );
    });
  });

  group('JsonObjectReader.requiredObject', () {
    test('reads an object and extends its path', () {
      final diagnostics = DiagnosticCollector();
      final reader = _reader({
        'permissions': <String, Object?>{'network': <String, Object?>{}},
      }, diagnostics);

      final child = reader.requiredObject('permissions');

      expect(child?.path.toString(), r'$.permissions');
      expect(child?.requiredObject('network')?.path.toString(), r'$.permissions.network');
      expect(diagnostics.diagnostics, isEmpty);
    });

    test('reports missing and non-object values', () {
      final missingDiagnostics = DiagnosticCollector();
      final mismatchedDiagnostics = DiagnosticCollector();

      expect(_reader({}, missingDiagnostics).requiredObject('permissions'), isNull);
      expect(
        _reader({'permissions': []}, mismatchedDiagnostics).requiredObject('permissions'),
        isNull,
      );
      expect(missingDiagnostics.diagnostics.single.code, 'manifest.field.missing');
      _expectDiagnostic(
        mismatchedDiagnostics,
        code: 'manifest.field.type_mismatch',
        path: r'$.permissions',
        message: 'Expected object, got array.',
      );
    });
  });

  group('JsonObjectReader.optionalObject', () {
    test('reads an object and ignores an absent field', () {
      final diagnostics = DiagnosticCollector();
      final reader = _reader({'permissions': <String, Object?>{}}, diagnostics);

      expect(reader.optionalObject('permissions')?.path.toString(), r'$.permissions');
      expect(reader.optionalObject('metadata'), isNull);
      expect(diagnostics.diagnostics, isEmpty);
    });

    test('reports a type mismatch', () {
      final diagnostics = DiagnosticCollector();
      final reader = _reader({'permissions': 'network'}, diagnostics);

      expect(reader.optionalObject('permissions'), isNull);
      _expectDiagnostic(
        diagnostics,
        code: 'manifest.field.type_mismatch',
        path: r'$.permissions',
        message: 'Expected object, got string.',
      );
    });
  });

  group('JsonObjectReader.optionalObjectList', () {
    test('reads objects with indexed paths and ignores an absent field', () {
      final diagnostics = DiagnosticCollector();
      final reader = _reader({
        'settings': <Object?>[
          <String, Object?>{'id': 'language'},
          <String, Object?>{'id': 'token'},
        ],
      }, diagnostics);

      final settings = reader.optionalObjectList('settings');

      expect(settings.map((item) => item.path.toString()), [r'$.settings[0]', r'$.settings[1]']);
      expect(reader.optionalObjectList('other'), isEmpty);
      expect(diagnostics.diagnostics, isEmpty);
    });

    test('reports malformed fields and elements without throwing', () {
      final fieldDiagnostics = DiagnosticCollector();
      final elementDiagnostics = DiagnosticCollector();

      expect(_reader({'settings': {}}, fieldDiagnostics).optionalObjectList('settings'), isEmpty);
      expect(
        _reader({
          'settings': <Object?>[<String, Object?>{}, 'invalid', <String, Object?>{}],
        }, elementDiagnostics).optionalObjectList('settings'),
        hasLength(2),
      );
      expect(fieldDiagnostics.diagnostics.single.path.toString(), r'$.settings');
      expect(elementDiagnostics.diagnostics.single.path.toString(), r'$.settings[1]');
    });
  });

  group('JsonObjectReader.optionalStringList', () {
    test('reads strings and ignores an absent field', () {
      final diagnostics = DiagnosticCollector();
      final reader = _reader({
        'hosts': <Object?>['api.example.com', '*.cdn.example.com'],
      }, diagnostics);

      expect(reader.optionalStringList('hosts'), ['api.example.com', '*.cdn.example.com']);
      expect(reader.optionalStringList('other'), isEmpty);
      expect(diagnostics.diagnostics, isEmpty);
    });

    test('reports malformed fields and elements without throwing', () {
      final fieldDiagnostics = DiagnosticCollector();
      final elementDiagnostics = DiagnosticCollector();

      expect(_reader({'hosts': false}, fieldDiagnostics).optionalStringList('hosts'), isEmpty);
      expect(
        _reader({
          'hosts': <Object?>['api.example.com', 1, '*.cdn.example.com'],
        }, elementDiagnostics).optionalStringList('hosts'),
        ['api.example.com', '*.cdn.example.com'],
      );
      expect(fieldDiagnostics.diagnostics.single.path.toString(), r'$.hosts');
      expect(elementDiagnostics.diagnostics.single.path.toString(), r'$.hosts[1]');
    });
  });

  group('JsonObjectReader.reportUnknownFields', () {
    test('reports only unknown fields in source order', () {
      final diagnostics = DiagnosticCollector();
      _reader({
        'id': 'dev.shinga.foo',
        'first': 1,
        'name': 'Foo',
        'second': 2,
      }, diagnostics).reportUnknownFields({'id', 'name'});

      expect(diagnostics.diagnostics.map((item) => item.code), [
        'manifest.field.unknown',
        'manifest.field.unknown',
      ]);
      expect(diagnostics.diagnostics.map((item) => item.path.toString()), [
        r'$.first',
        r'$.second',
      ]);
      expect(
        diagnostics.diagnostics.every((item) => item.severity == DiagnosticSeverity.warning),
        isTrue,
      );
    });
  });
}

JsonObjectReader _reader(JsonObject value, DiagnosticCollector diagnostics) {
  return JsonObjectReader(value: value, path: const JsonPath.root(), diagnostics: diagnostics);
}

void _expectDiagnostic(
  DiagnosticCollector collector, {
  required String code,
  required String path,
  required String message,
}) {
  final diagnostic = collector.diagnostics.single;
  expect(diagnostic.code, code);
  expect(diagnostic.path.toString(), path);
  expect(diagnostic.message, message);
}
