import 'package:plugin_protocol/src/common/diagnostics/diagnostics.dart';
import 'package:plugin_protocol/src/common/json_object_reader.dart';
import 'package:plugin_protocol/src/localization/locale_tag.dart';
import 'package:plugin_protocol/src/localization/localized_text.dart';

const DiagnosticCode _emptyLocalizedTextCode = 'manifest.localized_text.empty';
const DiagnosticCode _invalidLocaleCode = 'manifest.localized_text.invalid_locale';
const DiagnosticCode _emptyLocalizedValueCode = 'manifest.localized_text.empty_value';
const DiagnosticCode _duplicateLocaleCode = 'manifest.localized_text.duplicate_locale';

/// Decodes localized text while reporting every malformed entry.
LocalizedText? decodeLocalizedText(
  JsonObjectReader reader,
  DiagnosticCollector diagnostics,
) {
  if (reader.value.isEmpty) {
    diagnostics.error(
      code: _emptyLocalizedTextCode,
      path: reader.path,
      message: 'Localized text must contain at least one value.',
    );
    return null;
  }

  final valueReader = JsonObjectReader(
    value: reader.value,
    path: reader.path,
    diagnostics: diagnostics,
  );
  final values = <LocaleTag, String>{};
  final seenLocales = <LocaleTag>{};
  var isValid = true;

  for (final entry in reader.value.entries) {
    final rawLocale = entry.key;
    final entryPath = reader.path.field(rawLocale);
    final locale = LocaleTag.tryParse(rawLocale);
    final text = valueReader.requiredString(rawLocale);

    if (locale == null) {
      diagnostics.error(
        code: _invalidLocaleCode,
        path: entryPath,
        message: 'Invalid locale tag "$rawLocale".',
      );
      isValid = false;
    }

    final isDuplicate = locale != null && !seenLocales.add(locale);
    if (isDuplicate) {
      diagnostics.error(
        code: _duplicateLocaleCode,
        path: entryPath,
        message: 'Locale "$locale" is duplicated after normalization.',
      );
      isValid = false;
    }

    if (text == null) {
      isValid = false;
    } else if (text.trim().isEmpty) {
      diagnostics.error(
        code: _emptyLocalizedValueCode,
        path: entryPath,
        message: 'Localized text must not be empty.',
      );
      isValid = false;
    } else if (locale != null && !isDuplicate) {
      values[locale] = text;
    }
  }

  return isValid ? LocalizedText(values) : null;
}
