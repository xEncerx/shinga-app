import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_protocol/src/common/common.dart';
import 'package:plugin_protocol/src/manifest/parsing/setting_definition_decoder.dart';
import 'package:test/test.dart';

void main() {
  group('decodePluginSettingDefinition valid settings', () {
    test('decodes text settings', () {
      final outcome = _decode(
        _setting('text', {'required': true, 'defaultValue': 'Initial value'}),
      );

      expect(outcome.result, isA<TextPluginSettingDefinition>());
      final setting = outcome.result! as TextPluginSettingDefinition;
      expect(setting.id, 'settingId');
      expect(setting.required, isTrue);
      expect(setting.defaultValue, 'Initial value');
      expect(setting.label.values[LocaleTag.tryParse('en')], 'Label');
      expect(outcome.diagnostics.diagnostics, isEmpty);
    });

    test('decodes secret settings', () {
      final outcome = _decode(_setting('secret'));

      expect(outcome.result, isA<SecretPluginSettingDefinition>());
      expect(outcome.result?.required, isFalse);
      expect(outcome.diagnostics.diagnostics, isEmpty);
    });

    test('decodes boolean settings with a false default when absent', () {
      final absentDefault = _decode(_setting('boolean'));
      final explicitDefault = _decode(_setting('boolean', {'defaultValue': true}));

      expect(
        (absentDefault.result! as BooleanPluginSettingDefinition).defaultValue,
        isFalse,
      );
      expect(
        (explicitDefault.result! as BooleanPluginSettingDefinition).defaultValue,
        isTrue,
      );
      expect(absentDefault.diagnostics.diagnostics, isEmpty);
      expect(explicitDefault.diagnostics.diagnostics, isEmpty);
    });

    test('decodes numeric settings without losing integer precision', () {
      const maxSafeJavaScriptInteger = 0x1FFFFFFFFFFFFF;
      const largeIntegerValue = maxSafeJavaScriptInteger + 2;
      final withDefault = _decode(_setting('num', {'defaultValue': 5}));
      final largeInteger = _decode(
        _setting('num', {'defaultValue': largeIntegerValue}),
      );
      final withoutDefault = _decode(_setting('num'));

      expect((withDefault.result! as NumberPluginSettingDefinition).defaultValue, 5);
      expect(
        (largeInteger.result! as NumberPluginSettingDefinition).defaultValue,
        largeIntegerValue,
      );
      expect((withoutDefault.result! as NumberPluginSettingDefinition).defaultValue, isNull);
      expect(withDefault.diagnostics.diagnostics, isEmpty);
      expect(withoutDefault.diagnostics.diagnostics, isEmpty);
    });

    test('decodes select settings', () {
      final outcome = _decode(
        _setting('select', {'options': _options(), 'defaultValue': 'a'}),
      );

      expect(outcome.result, isA<SelectPluginSettingDefinition>());
      final setting = outcome.result! as SelectPluginSettingDefinition;
      expect(setting.options.map((option) => option.value), ['a', 'b']);
      expect(setting.defaultValue, 'a');
      expect(outcome.diagnostics.diagnostics, isEmpty);
    });

    test('decodes multi-select settings', () {
      final outcome = _decode(
        _setting('multiSelect', {
          'options': _options(),
          'defaultValue': <Object?>['a', 'b'],
        }),
      );

      expect(outcome.result, isA<MultiSelectPluginSettingDefinition>());
      final setting = outcome.result! as MultiSelectPluginSettingDefinition;
      expect(setting.options.map((option) => option.value), ['a', 'b']);
      expect(setting.defaultValue, ['a', 'b']);
      expect(outcome.diagnostics.diagnostics, isEmpty);
    });

    test('allows absent selection defaults and an empty multi-select default', () {
      final select = _decode(_setting('select', {'options': _options()}));
      final multiSelect = _decode(
        _setting('multiSelect', {'options': _options(), 'defaultValue': <Object?>[]}),
      );

      expect((select.result! as SelectPluginSettingDefinition).defaultValue, isNull);
      expect(
        (multiSelect.result! as MultiSelectPluginSettingDefinition).defaultValue,
        isEmpty,
      );
    });

    test('leaves an omitted description null without diagnostics', () {
      final outcome = _decode(_setting('text'));

      expect(outcome.result?.description, isNull);
      expect(outcome.diagnostics.diagnostics, isEmpty);
    });

    test('preserves localized Markdown description sources exactly', () {
      const singleSource = '**Required** for API access.\n';
      const englishSource = '  Keep [this link](https://example.test) as source.  ';
      const russianSource = 'Первая строка\n\nВторая строка';
      final singleLocale = _decode(
        _setting('text', {
          'description': <String, Object?>{'en': singleSource},
        }),
      );
      final multipleLocales = _decode(
        _setting('text', {
          'description': <String, Object?>{
            'EN': englishSource,
            'ru': russianSource,
          },
        }),
      );

      expect(
        singleLocale.result?.description?.values[LocaleTag.tryParse('en')],
        singleSource,
      );
      expect(
        multipleLocales.result?.description?.values,
        {
          LocaleTag.tryParse('en'): englishSource,
          LocaleTag.tryParse('ru'): russianSource,
        },
      );
      expect(singleLocale.diagnostics.diagnostics, isEmpty);
      expect(multipleLocales.diagnostics.diagnostics, isEmpty);
    });

    test('accepts descriptions for every setting type without unknown-field warnings', () {
      for (final type in [
        'text',
        'secret',
        'boolean',
        'num',
        'select',
        'multiSelect',
      ]) {
        final outcome = _decode(
          _setting(type, {
            'description': <String, Object?>{'en': 'Why $type is needed.'},
            if (type == 'select' || type == 'multiSelect') 'options': _options(),
          }),
        );

        expect(outcome.result, isNotNull, reason: type);
        expect(
          outcome.result?.description?.values[LocaleTag.tryParse('en')],
          'Why $type is needed.',
          reason: type,
        );
        expect(outcome.diagnostics.diagnostics, isEmpty, reason: type);
      }
    });
  });

  group('decodePluginSettingDefinition common validation', () {
    test('rejects an unknown type', () {
      final outcome = _decode(_setting('color'));

      expect(outcome.result, isNull);
      _expectError(
        outcome.diagnostics,
        code: 'manifest.setting.type.unknown',
        path: r'$.settings[0].type',
        message: 'Unknown setting type "color".',
      );
    });

    test('rejects a missing id', () {
      final setting = _setting('text')..remove('id');

      final outcome = _decode(setting);

      expect(outcome.result, isNull);
      _expectError(
        outcome.diagnostics,
        code: 'manifest.field.missing',
        path: r'$.settings[0].id',
        message: 'Required field is missing.',
      );
    });

    test('rejects an empty id', () {
      final outcome = _decode(_setting('text', {'id': '  '}));

      expect(outcome.result, isNull);
      _expectError(
        outcome.diagnostics,
        code: 'manifest.setting.id.empty',
        path: r'$.settings[0].id',
        message: 'Setting id must not be empty.',
      );
    });

    test('rejects an invalid localized label', () {
      final outcome = _decode(_setting('text', {'label': <String, Object?>{}}));

      expect(outcome.result, isNull);
      _expectError(
        outcome.diagnostics,
        code: 'manifest.localized_text.empty',
        path: r'$.settings[0].label',
        message: 'Localized text must contain at least one value.',
      );
    });

    test('defaults required to false and reads an explicit true value', () {
      final defaultRequired = _decode(_setting('text'));
      final explicitRequired = _decode(_setting('text', {'required': true}));

      expect(defaultRequired.result?.required, isFalse);
      expect(explicitRequired.result?.required, isTrue);
    });

    test('reports unknown fields as warnings without rejecting the setting', () {
      final outcome = _decode(_setting('text', {'unexpected': 1}));

      expect(outcome.result, isA<TextPluginSettingDefinition>());
      expect(outcome.diagnostics.hasErrors, isFalse);
      final warning = outcome.diagnostics.diagnostics.single;
      expect(warning.code, 'manifest.field.unknown');
      expect(warning.severity, DiagnosticSeverity.warning);
      expect(warning.path.toString(), r'$.settings[0].unexpected');
    });

    test('rejects wrong-type and null descriptions with existing type errors', () {
      for (final testCase in [
        (value: 'Markdown', message: 'Expected object, got string.'),
        (value: null, message: 'Expected object, got null.'),
      ]) {
        final outcome = _decode(
          _setting('text', {'description': testCase.value}),
        );

        expect(outcome.result, isNull);
        _expectError(
          outcome.diagnostics,
          code: 'manifest.field.type_mismatch',
          path: r'$.settings[0].description',
          message: testCase.message,
        );
      }
    });

    test('rejects empty and blank descriptions with existing localized-text errors', () {
      final empty = _decode(
        _setting('text', {'description': <String, Object?>{}}),
      );
      final blank = _decode(
        _setting('text', {
          'description': <String, Object?>{'en': '  \n '},
        }),
      );

      expect(empty.result, isNull);
      expect(blank.result, isNull);
      _expectError(
        empty.diagnostics,
        code: 'manifest.localized_text.empty',
        path: r'$.settings[0].description',
        message: 'Localized text must contain at least one value.',
      );
      _expectError(
        blank.diagnostics,
        code: 'manifest.localized_text.empty_value',
        path: r'$.settings[0].description.en',
        message: 'Localized text must not be empty.',
      );
    });

    test('retains invalid and duplicate locale validation for descriptions', () {
      final invalid = _decode(
        _setting('text', {
          'description': <String, Object?>{'en_US': 'Invalid locale'},
        }),
      );
      final duplicate = _decode(
        _setting('text', {
          'description': <String, Object?>{
            'EN': 'First',
            'en': 'Second',
          },
        }),
      );

      expect(invalid.result, isNull);
      expect(duplicate.result, isNull);
      _expectError(
        invalid.diagnostics,
        code: 'manifest.localized_text.invalid_locale',
        path: r'$.settings[0].description.en_US',
        message: 'Invalid locale tag "en_US".',
      );
      _expectError(
        duplicate.diagnostics,
        code: 'manifest.localized_text.duplicate_locale',
        path: r'$.settings[0].description.en',
        message: 'Locale "en" is duplicated after normalization.',
      );
    });
  });

  group('decodePluginSettingDefinition description length', () {
    test('accepts 3999 and 4000 grapheme clusters', () {
      for (final length in [3999, 4000]) {
        final source = 'a' * length;
        final outcome = _decode(
          _setting('text', {
            'description': <String, Object?>{'en': source},
          }),
        );

        expect(outcome.result?.description?.values.values.single, source);
        expect(outcome.diagnostics.diagnostics, isEmpty);
      }
    });

    test('counts combining sequences and ZWJ emoji as grapheme clusters', () {
      const combiningSequence = 'e\u0301';
      const familyEmoji = '\u{1F468}\u200D\u{1F469}\u200D\u{1F467}\u200D\u{1F466}';
      final source = '${combiningSequence * 2000}${familyEmoji * 2000}';
      final outcome = _decode(
        _setting('text', {
          'description': <String, Object?>{'en': source},
        }),
      );

      expect(outcome.result?.description?.values.values.single, source);
      expect(outcome.diagnostics.diagnostics, isEmpty);
    });

    test('rejects 4001 grapheme clusters at the source locale path', () {
      final outcome = _decode(
        _setting('text', {
          'description': <String, Object?>{
            'ru': 'a' * 4000,
            'EN': 'a' * 4001,
          },
        }),
      );

      expect(outcome.result, isNull);
      _expectError(
        outcome.diagnostics,
        code: 'manifest.setting.description.too_long',
        path: r'$.settings[0].description.EN',
        message: 'Setting description must not exceed 4000 characters.',
      );
    });

    test('does not apply the description limit to generic localized labels', () {
      final outcome = _decode(
        _setting('text', {
          'label': <String, Object?>{'en': 'a' * 4001},
        }),
      );

      expect(outcome.result, isNotNull);
      expect(outcome.diagnostics.diagnostics, isEmpty);
    });
  });

  group('decodePluginSettingDefinition default validation', () {
    test('rejects wrong default types for every applicable setting', () {
      final invalidSettings = <JsonObject>[
        _setting('text', {'defaultValue': 1}),
        _setting('boolean', {'defaultValue': 'false'}),
        _setting('num', {'defaultValue': '1'}),
        _setting('select', {'options': _options(), 'defaultValue': 1}),
        _setting('multiSelect', {'options': _options(), 'defaultValue': 'a'}),
      ];

      for (final setting in invalidSettings) {
        final outcome = _decode(setting);
        final type = setting['type']! as String;
        expect(outcome.result, isNull, reason: type);
        expect(
          outcome.diagnostics.diagnostics.any(
            (diagnostic) => diagnostic.code == 'manifest.field.type_mismatch',
          ),
          isTrue,
          reason: type,
        );
      }
    });

    test('rejects a secret default even when it is null', () {
      final stringDefault = _decode(_setting('secret', {'defaultValue': 'token'}));
      final nullDefault = _decode(_setting('secret', {'defaultValue': null}));

      for (final outcome in [stringDefault, nullDefault]) {
        expect(outcome.result, isNull);
        _expectError(
          outcome.diagnostics,
          code: 'manifest.setting.secret.default_forbidden',
          path: r'$.settings[0].defaultValue',
          message: 'Secret settings must not declare a default value.',
        );
      }
    });

    test('rejects non-finite numeric defaults', () {
      final outcome = _decode(_setting('num', {'defaultValue': double.infinity}));

      expect(outcome.result, isNull);
      _expectError(
        outcome.diagnostics,
        code: 'manifest.setting.number.non_finite',
        path: r'$.settings[0].defaultValue',
        message: 'Expected a finite number.',
      );
    });
  });

  group('decodePluginSettingDefinition selection validation', () {
    test('rejects missing, non-array, and empty options', () {
      final missing = _decode(_setting('select'));
      final wrongType = _decode(_setting('select', {'options': 'a'}));
      final empty = _decode(_setting('select', {'options': <Object?>[]}));

      expect(missing.result, isNull);
      expect(wrongType.result, isNull);
      expect(empty.result, isNull);
      expect(missing.diagnostics.diagnostics.single.code, 'manifest.field.missing');
      expect(wrongType.diagnostics.diagnostics.single.code, 'manifest.field.type_mismatch');
      expect(empty.diagnostics.diagnostics.single.code, 'manifest.setting.options.empty');
    });

    test('rejects duplicate option values', () {
      final outcome = _decode(
        _setting('select', {
          'options': <Object?>[_option('a'), _option('a')],
        }),
      );

      expect(outcome.result, isNull);
      _expectError(
        outcome.diagnostics,
        code: 'manifest.setting.option.value.duplicate',
        path: r'$.settings[0].options[1].value',
        message: 'Option value "a" is duplicated.',
      );
    });

    test('rejects empty option values and invalid option labels', () {
      final emptyValue = _decode(
        _setting('select', {
          'options': <Object?>[
            _option(' ', label: <String, Object?>{'en': 'Blank'}),
          ],
        }),
      );
      final invalidLabel = _decode(
        _setting('select', {
          'options': <Object?>[
            _option('a', label: <String, Object?>{}),
          ],
        }),
      );

      expect(emptyValue.result, isNull);
      expect(invalidLabel.result, isNull);
      expect(
        emptyValue.diagnostics.diagnostics.single.code,
        'manifest.setting.option.value.empty',
      );
      expect(
        invalidLabel.diagnostics.diagnostics.single.code,
        'manifest.localized_text.empty',
      );
    });

    test('rejects a select default absent from options', () {
      final outcome = _decode(
        _setting('select', {'options': _options(), 'defaultValue': 'missing'}),
      );

      expect(outcome.result, isNull);
      _expectError(
        outcome.diagnostics,
        code: 'manifest.setting.default.not_in_options',
        path: r'$.settings[0].defaultValue',
        message: 'Default value "missing" is not declared in options.',
      );
    });

    test('rejects multi-select defaults absent from options or duplicated', () {
      final outcome = _decode(
        _setting('multiSelect', {
          'options': _options(),
          'defaultValue': <Object?>['a', 'missing', 'a'],
        }),
      );

      expect(outcome.result, isNull);
      expect(outcome.diagnostics.diagnostics.map((item) => item.code), [
        'manifest.setting.default.not_in_options',
        'manifest.setting.default.duplicate',
      ]);
      expect(outcome.diagnostics.diagnostics.map((item) => item.path.toString()), [
        r'$.settings[0].defaultValue[1]',
        r'$.settings[0].defaultValue[2]',
      ]);
    });

    test('reports malformed option entries and option unknown fields', () {
      final malformed = _decode(
        _setting('select', {
          'options': <Object?>['invalid'],
        }),
      );
      final unknownField = _decode(
        _setting('select', {
          'options': <Object?>[_option('a')..['unexpected'] = true],
        }),
      );

      expect(malformed.result, isNull);
      expect(malformed.diagnostics.diagnostics.single.path.toString(), r'$.settings[0].options[0]');
      expect(unknownField.result, isA<SelectPluginSettingDefinition>());
      expect(unknownField.diagnostics.diagnostics.single.severity, DiagnosticSeverity.warning);
      expect(
        unknownField.diagnostics.diagnostics.single.path.toString(),
        r'$.settings[0].options[0].unexpected',
      );
    });
  });

  group('setting model immutability', () {
    test('copies option and multi-select default lists', () {
      final options = <PluginSettingOption>[
        PluginSettingOption(
          value: 'a',
          label: LocalizedText({LocaleTag.tryParse('en')!: 'A'}),
        ),
      ];
      final defaults = <String>['a'];
      final setting = MultiSelectPluginSettingDefinition(
        id: 'settingId',
        label: LocalizedText({LocaleTag.tryParse('en')!: 'Label'}),
        required: false,
        options: options,
        defaultValue: defaults,
      );

      options.clear();
      defaults.clear();

      expect(setting.options, hasLength(1));
      expect(setting.defaultValue, ['a']);
      expect(setting.options.clear, throwsUnsupportedError);
      expect(() => setting.defaultValue?.clear(), throwsUnsupportedError);
    });
  });
}

({PluginSettingDefinition? result, DiagnosticCollector diagnostics}) _decode(JsonObject value) {
  final diagnostics = DiagnosticCollector();
  final reader = JsonObjectReader(
    value: value,
    path: const JsonPath.root().field('settings').index(0),
    diagnostics: diagnostics,
  );
  return (
    result: decodePluginSettingDefinition(reader, diagnostics),
    diagnostics: diagnostics,
  );
}

JsonObject _setting(String type, [JsonObject extra = const {}]) {
  return <String, Object?>{
    'id': 'settingId',
    'label': <String, Object?>{'en': 'Label'},
    'type': type,
    ...extra,
  };
}

JsonArray _options() => <Object?>[_option('a'), _option('b')];

JsonObject _option(String value, {JsonObject? label}) {
  return <String, Object?>{
    'value': value,
    'label': label ?? <String, Object?>{'en': value.toUpperCase()},
  };
}

void _expectError(
  DiagnosticCollector diagnostics, {
  required String code,
  required String path,
  required String message,
}) {
  final diagnostic = diagnostics.diagnostics.firstWhere((item) => item.code == code);
  expect(diagnostic.severity, DiagnosticSeverity.error);
  expect(diagnostic.path.toString(), path);
  expect(diagnostic.message, message);
}
