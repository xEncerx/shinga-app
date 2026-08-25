import 'package:plugin_protocol/src/common/common.dart';
import 'package:plugin_protocol/src/localization/localization.dart';
import 'package:plugin_protocol/src/manifest/models/models.dart';

typedef _CommonSettingFields = ({String? id, LocalizedText? label, bool required});
typedef _DecodedOptions = ({List<PluginSettingOption> options, Set<String> values});

const Set<String> _commonFields = {'id', 'label', 'required', 'type'};
const Set<String> _defaultFields = {..._commonFields, 'defaultValue'};
const Set<String> _selectionFields = {..._defaultFields, 'options'};
const Set<String> _knownSettingFields = {..._selectionFields};
const Set<String> _optionFields = {'label', 'value'};

const DiagnosticCode _emptyIdCode = 'manifest.setting.id.empty';
const DiagnosticCode _unknownTypeCode = 'manifest.setting.type.unknown';
const DiagnosticCode _forbiddenSecretDefaultCode = 'manifest.setting.secret.default_forbidden';
const DiagnosticCode _nonFiniteNumberCode = 'manifest.setting.number.non_finite';
const DiagnosticCode _emptyOptionsCode = 'manifest.setting.options.empty';
const DiagnosticCode _emptyOptionValueCode = 'manifest.setting.option.value.empty';
const DiagnosticCode _duplicateOptionValueCode = 'manifest.setting.option.value.duplicate';
const DiagnosticCode _defaultNotInOptionsCode = 'manifest.setting.default.not_in_options';
const DiagnosticCode _duplicateDefaultValueCode = 'manifest.setting.default.duplicate';

/// Decodes one plugin setting definition and reports all malformed fields.
PluginSettingDefinition? decodePluginSettingDefinition(
  JsonObjectReader reader,
  DiagnosticCollector diagnostics,
) {
  final initialDiagnosticCount = diagnostics.diagnostics.length;
  final valueReader = JsonObjectReader(
    value: reader.value,
    path: reader.path,
    diagnostics: diagnostics,
  );

  final id = valueReader.requiredString('id');
  if (id != null && id.trim().isEmpty) {
    diagnostics.error(
      code: _emptyIdCode,
      path: reader.path.field('id'),
      message: 'Setting id must not be empty.',
    );
  }

  final labelReader = valueReader.requiredObject('label');
  final label = labelReader == null ? null : decodeLocalizedText(labelReader, diagnostics);
  final required = valueReader.optionalBool('required') ?? false;
  final common = (id: id, label: label, required: required);

  final type = valueReader.requiredString('type');
  final setting = switch (type) {
    'text' => _decodeText(valueReader, common),
    'secret' => _decodeSecret(valueReader, common, diagnostics),
    'boolean' => _decodeBoolean(valueReader, common),
    'num' => _decodeNumber(valueReader, common, diagnostics),
    'select' => _decodeSelect(valueReader, common, diagnostics),
    'multiSelect' => _decodeMultiSelect(valueReader, common, diagnostics),
    null => _reportUnknownFields(valueReader),
    _ => _reportUnknownType(valueReader, diagnostics, type),
  };

  if (diagnostics.hasErrorsSince(initialDiagnosticCount)) {
    return null;
  }
  return setting;
}

TextPluginSettingDefinition? _decodeText(
  JsonObjectReader reader,
  _CommonSettingFields common,
) {
  final defaultValue = reader.optionalString('defaultValue');
  reader.reportUnknownFields(_defaultFields);

  final id = common.id;
  final label = common.label;
  if (id == null || label == null) {
    return null;
  }
  return TextPluginSettingDefinition(
    id: id,
    label: label,
    required: common.required,
    defaultValue: defaultValue,
  );
}

SecretPluginSettingDefinition? _decodeSecret(
  JsonObjectReader reader,
  _CommonSettingFields common,
  DiagnosticCollector diagnostics,
) {
  if (reader.value.containsKey('defaultValue')) {
    diagnostics.error(
      code: _forbiddenSecretDefaultCode,
      path: reader.path.field('defaultValue'),
      message: 'Secret settings must not declare a default value.',
    );
  }
  reader.reportUnknownFields(_defaultFields);

  final id = common.id;
  final label = common.label;
  if (id == null || label == null) {
    return null;
  }
  return SecretPluginSettingDefinition(
    id: id,
    label: label,
    required: common.required,
  );
}

BooleanPluginSettingDefinition? _decodeBoolean(
  JsonObjectReader reader,
  _CommonSettingFields common,
) {
  final defaultValue = reader.optionalBool('defaultValue') ?? false;
  reader.reportUnknownFields(_defaultFields);

  final id = common.id;
  final label = common.label;
  if (id == null || label == null) {
    return null;
  }
  return BooleanPluginSettingDefinition(
    id: id,
    label: label,
    required: common.required,
    defaultValue: defaultValue,
  );
}

NumberPluginSettingDefinition? _decodeNumber(
  JsonObjectReader reader,
  _CommonSettingFields common,
  DiagnosticCollector diagnostics,
) {
  final defaultValue = _optionalFiniteNumber(reader, diagnostics, 'defaultValue');
  reader.reportUnknownFields(_defaultFields);

  final id = common.id;
  final label = common.label;
  if (id == null || label == null) {
    return null;
  }
  return NumberPluginSettingDefinition(
    id: id,
    label: label,
    required: common.required,
    defaultValue: defaultValue,
  );
}

SelectPluginSettingDefinition? _decodeSelect(
  JsonObjectReader reader,
  _CommonSettingFields common,
  DiagnosticCollector diagnostics,
) {
  final decodedOptions = _decodeOptions(reader, diagnostics);
  final defaultValue = reader.optionalString('defaultValue');
  if (defaultValue != null && !decodedOptions.values.contains(defaultValue)) {
    _reportDefaultNotInOptions(
      diagnostics,
      path: reader.path.field('defaultValue'),
      value: defaultValue,
    );
  }
  reader.reportUnknownFields(_selectionFields);

  final id = common.id;
  final label = common.label;
  if (id == null || label == null) {
    return null;
  }
  return SelectPluginSettingDefinition(
    id: id,
    label: label,
    required: common.required,
    options: decodedOptions.options,
    defaultValue: defaultValue,
  );
}

MultiSelectPluginSettingDefinition? _decodeMultiSelect(
  JsonObjectReader reader,
  _CommonSettingFields common,
  DiagnosticCollector diagnostics,
) {
  final decodedOptions = _decodeOptions(reader, diagnostics);
  final defaultValue = _decodeMultiSelectDefault(
    reader,
    diagnostics,
    decodedOptions.values,
  );
  reader.reportUnknownFields(_selectionFields);

  final id = common.id;
  final label = common.label;
  if (id == null || label == null) {
    return null;
  }
  return MultiSelectPluginSettingDefinition(
    id: id,
    label: label,
    required: common.required,
    options: decodedOptions.options,
    defaultValue: defaultValue,
  );
}

_DecodedOptions _decodeOptions(
  JsonObjectReader reader,
  DiagnosticCollector diagnostics,
) {
  final optionsPath = reader.path.field('options');
  if (!reader.value.containsKey('options')) {
    diagnostics.reportMissingField(optionsPath);
    return (options: const [], values: const {});
  }

  final rawOptions = reader.value['options'];
  if (rawOptions is! JsonArray) {
    diagnostics.reportTypeMismatch(
      path: optionsPath,
      expected: 'array',
      actual: rawOptions,
    );
    return (options: const [], values: const {});
  }

  if (rawOptions.isEmpty) {
    diagnostics.error(
      code: _emptyOptionsCode,
      path: optionsPath,
      message: 'Selection settings must declare at least one option.',
    );
  }

  final options = <PluginSettingOption>[];
  final values = <String>{};
  for (final (index, rawOption) in rawOptions.indexed) {
    final optionPath = optionsPath.index(index);
    if (rawOption is! JsonObject) {
      diagnostics.reportTypeMismatch(
        path: optionPath,
        expected: 'object',
        actual: rawOption,
      );
      continue;
    }

    final optionReader = JsonObjectReader(
      value: rawOption,
      path: optionPath,
      diagnostics: diagnostics,
    );
    final option = _decodeOption(optionReader, diagnostics);
    if (option == null) {
      continue;
    }
    if (!values.add(option.value)) {
      diagnostics.error(
        code: _duplicateOptionValueCode,
        path: optionPath.field('value'),
        message: 'Option value "${option.value}" is duplicated.',
      );
      continue;
    }
    options.add(option);
  }
  return (options: options, values: values);
}

PluginSettingOption? _decodeOption(
  JsonObjectReader reader,
  DiagnosticCollector diagnostics,
) {
  final value = reader.requiredString('value');
  if (value != null && value.trim().isEmpty) {
    diagnostics.error(
      code: _emptyOptionValueCode,
      path: reader.path.field('value'),
      message: 'Option value must not be empty.',
    );
  }

  final labelReader = reader.requiredObject('label');
  final label = labelReader == null ? null : decodeLocalizedText(labelReader, diagnostics);
  reader.reportUnknownFields(_optionFields);

  if (value == null || value.trim().isEmpty || label == null) {
    return null;
  }
  return PluginSettingOption(value: value, label: label);
}

List<String>? _decodeMultiSelectDefault(
  JsonObjectReader reader,
  DiagnosticCollector diagnostics,
  Set<String> optionValues,
) {
  if (!reader.value.containsKey('defaultValue')) {
    return null;
  }

  final defaultPath = reader.path.field('defaultValue');
  final rawDefault = reader.value['defaultValue'];
  if (rawDefault is! JsonArray) {
    diagnostics.reportTypeMismatch(
      path: defaultPath,
      expected: 'array',
      actual: rawDefault,
    );
    return const [];
  }

  final values = <String>[];
  final seenValues = <String>{};
  for (final (index, rawValue) in rawDefault.indexed) {
    final valuePath = defaultPath.index(index);
    if (rawValue is! String) {
      diagnostics.reportTypeMismatch(
        path: valuePath,
        expected: 'string',
        actual: rawValue,
      );
      continue;
    }

    if (!optionValues.contains(rawValue)) {
      _reportDefaultNotInOptions(diagnostics, path: valuePath, value: rawValue);
    }
    if (!seenValues.add(rawValue)) {
      diagnostics.error(
        code: _duplicateDefaultValueCode,
        path: valuePath,
        message: 'Default value "$rawValue" is duplicated.',
      );
    }
    values.add(rawValue);
  }
  return values;
}

num? _optionalFiniteNumber(
  JsonObjectReader reader,
  DiagnosticCollector diagnostics,
  String key,
) {
  if (!reader.value.containsKey(key)) {
    return null;
  }

  final fieldPath = reader.path.field(key);
  final rawValue = reader.value[key];
  if (rawValue is! num) {
    diagnostics.reportTypeMismatch(
      path: fieldPath,
      expected: 'number',
      actual: rawValue,
    );
    return null;
  }

  if (!rawValue.isFinite) {
    diagnostics.error(
      code: _nonFiniteNumberCode,
      path: fieldPath,
      message: 'Expected a finite number.',
    );
    return null;
  }
  return rawValue;
}

PluginSettingDefinition? _reportUnknownType(
  JsonObjectReader reader,
  DiagnosticCollector diagnostics,
  String type,
) {
  diagnostics.error(
    code: _unknownTypeCode,
    path: reader.path.field('type'),
    message: 'Unknown setting type "$type".',
  );
  reader.reportUnknownFields(_knownSettingFields);
  return null;
}

PluginSettingDefinition? _reportUnknownFields(JsonObjectReader reader) {
  reader.reportUnknownFields(_knownSettingFields);
  return null;
}

void _reportDefaultNotInOptions(
  DiagnosticCollector diagnostics, {
  required JsonPath path,
  required String value,
}) {
  diagnostics.error(
    code: _defaultNotInOptionsCode,
    path: path,
    message: 'Default value "$value" is not declared in options.',
  );
}
