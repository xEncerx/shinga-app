import 'package:plugin_protocol/src/common/common.dart';
import 'package:plugin_protocol/src/manifest/models/models.dart';
import 'package:plugin_protocol/src/manifest/parsing/permissions_decoder.dart';
import 'package:plugin_protocol/src/manifest/parsing/setting_definition_decoder.dart';

const Set<String> _manifestV1Fields = {
  'entry',
  'icon',
  'id',
  'manifestVersion',
  'name',
  'permissions',
  'pluginApiVersion',
  'settings',
  'version',
};

const Set<String> _supportedIconExtensions = {
  '.apng',
  '.avif',
  '.bmp',
  '.gif',
  '.ico',
  '.jpeg',
  '.jpg',
  '.png',
  '.svg',
  '.svgz',
  '.tif',
  '.tiff',
  '.webp',
};

/// Decodes a validated JSON object using plugin manifest schema version 1.
PluginManifest? decodeManifestV1(
  JsonObjectReader reader,
  DiagnosticCollector diagnostics,
) {
  final initialDiagnosticCount = diagnostics.diagnostics.length;
  final valueReader = JsonObjectReader(
    value: reader.value,
    path: reader.path,
    diagnostics: diagnostics,
  );

  final manifestVersion = _decodeManifestVersion(valueReader, diagnostics);
  final id = _decodePluginId(valueReader, diagnostics);
  final name = _decodeName(valueReader, diagnostics);
  final version = _decodePluginVersion(valueReader, diagnostics);
  final pluginApiVersion = _decodePluginApiVersion(valueReader, diagnostics);
  final entry = _decodeEntry(valueReader, diagnostics);
  final icon = _decodeIcon(valueReader, diagnostics);

  final permissionsReader = valueReader.optionalObject('permissions');
  final permissions = decodePermissions(permissionsReader, diagnostics);
  final settings = _decodeSettings(valueReader, diagnostics);

  valueReader.reportUnknownFields(_manifestV1Fields);

  if (diagnostics.hasErrorsSince(initialDiagnosticCount) ||
      manifestVersion == null ||
      id == null ||
      name == null ||
      version == null ||
      pluginApiVersion == null ||
      entry == null ||
      permissions == null) {
    return null;
  }

  return PluginManifest(
    manifestVersion: manifestVersion,
    id: id,
    name: name,
    version: version,
    pluginApiVersion: pluginApiVersion,
    entry: entry,
    icon: icon,
    permissions: permissions,
    settings: settings,
  );
}

ManifestFormatVersion? _decodeManifestVersion(
  JsonObjectReader reader,
  DiagnosticCollector diagnostics,
) {
  final rawVersion = reader.requiredInt('manifestVersion');
  if (rawVersion == null) {
    return null;
  }

  final version = ManifestFormatVersion.tryParse(rawVersion);
  if (version == null) {
    diagnostics.error(
      code: 'manifest.version.invalid',
      path: reader.path.field('manifestVersion'),
      message: 'Manifest version must be a positive integer.',
    );
    return null;
  }
  if (version.value != 1) {
    diagnostics.error(
      code: 'manifest.version.unexpected',
      path: reader.path.field('manifestVersion'),
      message: 'Expected manifest version 1, got ${version.value}.',
    );
  }
  return version;
}

PluginId? _decodePluginId(
  JsonObjectReader reader,
  DiagnosticCollector diagnostics,
) {
  final rawId = reader.requiredString('id');
  if (rawId == null) {
    return null;
  }

  final id = PluginId.tryParse(rawId);
  if (id == null) {
    diagnostics.error(
      code: 'manifest.id.invalid',
      path: reader.path.field('id'),
      message: 'Invalid plugin id "$rawId".',
    );
  }
  return id;
}

String? _decodeName(
  JsonObjectReader reader,
  DiagnosticCollector diagnostics,
) {
  final name = reader.requiredString('name');
  if (name != null && name.trim().isEmpty) {
    diagnostics.error(
      code: 'manifest.name.empty',
      path: reader.path.field('name'),
      message: 'Plugin name must not be empty.',
    );
    return null;
  }
  return name;
}

PluginVersion? _decodePluginVersion(
  JsonObjectReader reader,
  DiagnosticCollector diagnostics,
) {
  final rawVersion = reader.requiredString('version');
  if (rawVersion == null) {
    return null;
  }

  final version = PluginVersion.tryParse(rawVersion);
  if (version == null) {
    diagnostics.error(
      code: 'manifest.plugin_version.invalid',
      path: reader.path.field('version'),
      message: 'Invalid plugin version "$rawVersion".',
    );
  }
  return version;
}

PluginApiVersion? _decodePluginApiVersion(
  JsonObjectReader reader,
  DiagnosticCollector diagnostics,
) {
  final rawVersion = reader.requiredInt('pluginApiVersion');
  if (rawVersion == null) {
    return null;
  }

  final version = PluginApiVersion.tryParse(rawVersion);
  if (version == null) {
    diagnostics.error(
      code: 'manifest.plugin_api_version.invalid',
      path: reader.path.field('pluginApiVersion'),
      message: 'Plugin API version must be a positive integer.',
    );
  }
  return version;
}

PluginEntryPath? _decodeEntry(
  JsonObjectReader reader,
  DiagnosticCollector diagnostics,
) {
  final rawEntry = reader.requiredString('entry');
  if (rawEntry == null) return null;

  final entry = PluginEntryPath.tryParse(rawEntry);
  if (entry == null) {
    diagnostics.error(
      code: 'manifest.entry.invalid',
      path: reader.path.field('entry'),
      message: 'Invalid plugin entry path "$rawEntry".',
    );
  }
  return entry;
}

String? _decodeIcon(
  JsonObjectReader reader,
  DiagnosticCollector diagnostics,
) {
  final icon = reader.optionalString('icon');
  if (icon == null) return null;

  final uri = Uri.tryParse(icon);
  final scheme = uri?.scheme.toLowerCase();
  final hasSupportedExtension =
      uri != null && _supportedIconExtensions.any(uri.path.toLowerCase().endsWith);
  if (uri == null ||
      (scheme != 'http' && scheme != 'https') ||
      uri.host.isEmpty ||
      !hasSupportedExtension) {
    diagnostics.error(
      code: 'manifest.icon.invalid',
      path: reader.path.field('icon'),
      message: 'Invalid plugin icon URL "$icon".',
    );
    return null;
  }
  return icon;
}

List<PluginSettingDefinition> _decodeSettings(
  JsonObjectReader reader,
  DiagnosticCollector diagnostics,
) {
  final settings = <PluginSettingDefinition>[];
  final settingIds = <String>{};

  for (final settingReader in reader.optionalObjectList('settings')) {
    final setting = decodePluginSettingDefinition(settingReader, diagnostics);
    if (setting == null) {
      continue;
    }
    if (!settingIds.add(setting.id)) {
      diagnostics.error(
        code: 'manifest.setting.id.duplicate',
        path: settingReader.path.field('id'),
        message: 'Setting id "${setting.id}" is duplicated.',
      );
      continue;
    }
    settings.add(setting);
  }
  return settings;
}
