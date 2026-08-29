import 'dart:convert';
import 'dart:io';

import 'package:plugin_protocol/plugin_protocol.dart';

const _pluginManifest = '''
{
  "manifestVersion": 1,
  "id": "dev.shinga.mangafoo",
  "name": "MangaFoo",
  "version": "1.0.0",
  "pluginApiVersion": 1,
  "entry": "dist/index.js",
  "icon": "https://mangafoo.test/favicon.png",
  "permissions": {
    "network": {
      "hosts": [
        "api.mangafoo.test",
        "*.cdn.mangafoo.test"
      ]
    }
  },
  "settings": [
    {
      "id": "searchPrefix",
      "type": "text",
      "label": {
        "en": "Search prefix",
        "ru": "Префикс поиска"
      },
      "defaultValue": ""
    },
    {
      "id": "apiToken",
      "type": "secret",
      "required": true,
      "label": {
        "en": "API token",
        "ru": "API-токен"
      },
      "description": {
        "en": "Required to authenticate with the **MangaFoo API**.",
        "ru": "Требуется для аутентификации в **MangaFoo API**."
      }
    },
    {
      "id": "adultContent",
      "type": "boolean",
      "label": {
        "en": "Adult content",
        "ru": "Контент 18+"
      },
      "defaultValue": false
    },
    {
      "id": "minimumRating",
      "type": "num",
      "label": {
        "en": "Minimum rating",
        "ru": "Минимальный рейтинг"
      },
      "defaultValue": 7.5
    },
    {
      "id": "contentLanguage",
      "type": "select",
      "required": true,
      "label": {
        "en": "Content language",
        "ru": "Язык контента"
      },
      "defaultValue": "en",
      "options": [
        {
          "value": "en",
          "label": {
            "en": "English",
            "ru": "Английский"
          }
        },
        {
          "value": "ru",
          "label": {
            "en": "Russian",
            "ru": "Русский"
          }
        }
      ]
    },
    {
      "id": "genres",
      "type": "multiSelect",
      "label": {
        "en": "Preferred genres",
        "ru": "Предпочитаемые жанры"
      },
      "defaultValue": [
        "action"
      ],
      "options": [
        {
          "value": "action",
          "label": {
            "en": "Action",
            "ru": "Боевик"
          }
        },
        {
          "value": "comedy",
          "label": {
            "en": "Comedy",
            "ru": "Комедия"
          }
        }
      ]
    }
  ]
}

''';

/// Parses the example manifest and prints its normalized representation.
void main() {
  final result = PluginManifestParser().parse(_pluginManifest);
  if (!result.isSuccess) {
    stderr.writeln('Manifest parsing failed.');
    _writeDiagnostics(result.diagnostics, output: stderr);
    exitCode = 1;
    return;
  }

  _writeManifest(result.manifest!);

  if (result.diagnostics.isNotEmpty) {
    stdout.writeln();
    _writeDiagnostics(result.diagnostics, output: stdout);
  }
}

void _writeManifest(PluginManifest manifest) {
  stdout
    ..writeln('Plugin manifest')
    ..writeln('  manifestVersion: ${manifest.manifestVersion.value}')
    ..writeln('  id: ${manifest.id.value}')
    ..writeln('  name: ${jsonEncode(manifest.name)}')
    ..writeln('  version: ${manifest.version.value}')
    ..writeln('  pluginApiVersion: ${manifest.pluginApiVersion.value}')
    ..writeln('  entry: ${jsonEncode(manifest.entry.value)}')
    ..writeln('  icon: ${jsonEncode(manifest.icon)}')
    ..writeln()
    ..writeln('Permissions');

  final network = manifest.permissions.network;
  if (network == null) {
    stdout.writeln('  network: denied');
  } else {
    stdout.writeln('  network hosts (${network.hosts.length}):');
    for (final pattern in network.hosts) {
      stdout
        ..writeln('    - pattern: $pattern')
        ..writeln('      host: ${pattern.host}')
        ..writeln('      includeSubdomains: ${pattern.includeSubdomains}');
    }
  }

  stdout
    ..writeln()
    ..writeln('Settings (${manifest.settings.length})');
  for (final (index, setting) in manifest.settings.indexed) {
    _writeSetting(index, setting);
  }
}

void _writeSetting(int index, PluginSettingDefinition setting) {
  stdout
    ..writeln('  [$index] ${_settingType(setting)}')
    ..writeln('    id: ${jsonEncode(setting.id)}')
    ..writeln('    required: ${setting.required}')
    ..writeln('    label:');
  _writeLocalizedText(setting.label, indentation: '      ');
  final description = setting.description;
  if (description != null) {
    stdout.writeln('    description:');
    _writeLocalizedText(description, indentation: '      ');
  }

  switch (setting) {
    case TextPluginSettingDefinition():
      _writeDefaultValue(setting.defaultValue);
    case SecretPluginSettingDefinition():
      stdout.writeln('    defaultValue: <not supported>');
    case BooleanPluginSettingDefinition():
      _writeDefaultValue(setting.defaultValue);
    case NumberPluginSettingDefinition():
      _writeDefaultValue(setting.defaultValue);
    case SelectPluginSettingDefinition():
      _writeDefaultValue(setting.defaultValue);
      _writeOptions(setting.options);
    case MultiSelectPluginSettingDefinition():
      _writeDefaultValue(setting.defaultValue);
      _writeOptions(setting.options);
  }
}

String _settingType(PluginSettingDefinition setting) {
  return switch (setting) {
    TextPluginSettingDefinition() => 'text',
    SecretPluginSettingDefinition() => 'secret',
    BooleanPluginSettingDefinition() => 'boolean',
    NumberPluginSettingDefinition() => 'num',
    SelectPluginSettingDefinition() => 'select',
    MultiSelectPluginSettingDefinition() => 'multiSelect',
  };
}

void _writeDefaultValue(Object? value) {
  stdout.writeln('    defaultValue: ${value == null ? '<none>' : jsonEncode(value)}');
}

void _writeOptions(List<PluginSettingOption> options) {
  stdout.writeln('    options (${options.length}):');
  for (final (index, option) in options.indexed) {
    stdout
      ..writeln('      [$index]')
      ..writeln('        value: ${jsonEncode(option.value)}')
      ..writeln('        label:');
    _writeLocalizedText(option.label, indentation: '          ');
  }
}

void _writeLocalizedText(LocalizedText text, {required String indentation}) {
  for (final entry in text.values.entries) {
    stdout.writeln('$indentation${entry.key}: ${jsonEncode(entry.value)}');
  }
}

void _writeDiagnostics(
  List<ManifestDiagnostic> diagnostics, {
  required IOSink output,
}) {
  output.writeln('Diagnostics (${diagnostics.length})');
  for (final (index, diagnostic) in diagnostics.indexed) {
    output
      ..writeln('  [$index] ${diagnostic.severity.name.toUpperCase()}')
      ..writeln('    code: ${diagnostic.code}')
      ..writeln('    path: ${diagnostic.path}')
      ..writeln('    message: ${diagnostic.message}');
  }
}
