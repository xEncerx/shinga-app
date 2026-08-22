import 'package:plugin_protocol/src/common/diagnostics/diagnostics.dart';
import 'package:plugin_protocol/src/common/json_value.dart';

/// Safely reads typed fields from a JSON object and reports malformed input.
final class JsonObjectReader {
  /// Creates a reader for [value] at [path].
  const JsonObjectReader({
    required this.value,
    required this.path,
    required this.diagnostics,
  });

  static const DiagnosticCode _unknownFieldCode = 'manifest.field.unknown';

  /// The JSON object being read.
  final JsonObject value;

  /// The path of [value] in the source document.
  final JsonPath path;

  /// The collector receiving input diagnostics.
  final DiagnosticCollector diagnostics;

  /// Reads a required string field or reports why it cannot be read.
  String? requiredString(String key) {
    final fieldPath = path.field(key);
    if (!value.containsKey(key)) {
      diagnostics.reportMissingField(fieldPath);
      return null;
    }

    final fieldValue = value[key];
    if (fieldValue is! String) {
      diagnostics.reportTypeMismatch(path: fieldPath, expected: 'string', actual: fieldValue);
      return null;
    }
    return fieldValue;
  }

  /// Reads an optional string field when present and correctly typed.
  String? optionalString(String key) {
    if (!value.containsKey(key)) {
      return null;
    }

    final fieldValue = value[key];
    if (fieldValue is! String) {
      diagnostics.reportTypeMismatch(
        path: path.field(key),
        expected: 'string',
        actual: fieldValue,
      );
      return null;
    }
    return fieldValue;
  }

  /// Reads a required integer field or reports why it cannot be read.
  int? requiredInt(String key) {
    final fieldPath = path.field(key);
    if (!value.containsKey(key)) {
      diagnostics.reportMissingField(fieldPath);
      return null;
    }

    final fieldValue = value[key];
    if (fieldValue is! int) {
      diagnostics.reportTypeMismatch(path: fieldPath, expected: 'integer', actual: fieldValue);
      return null;
    }
    return fieldValue;
  }

  /// Reads an optional boolean field when present and correctly typed.
  bool? optionalBool(String key) {
    if (!value.containsKey(key)) {
      return null;
    }

    final fieldValue = value[key];
    if (fieldValue is! bool) {
      diagnostics.reportTypeMismatch(
        path: path.field(key),
        expected: 'boolean',
        actual: fieldValue,
      );
      return null;
    }
    return fieldValue;
  }

  /// Reads a required object field or reports why it cannot be read.
  JsonObjectReader? requiredObject(String key) {
    final fieldPath = path.field(key);
    if (!value.containsKey(key)) {
      diagnostics.reportMissingField(fieldPath);
      return null;
    }

    final fieldValue = value[key];
    if (fieldValue is! JsonObject) {
      diagnostics.reportTypeMismatch(path: fieldPath, expected: 'object', actual: fieldValue);
      return null;
    }
    return JsonObjectReader(value: fieldValue, path: fieldPath, diagnostics: diagnostics);
  }

  /// Reads an optional object field when present and correctly typed.
  JsonObjectReader? optionalObject(String key) {
    if (!value.containsKey(key)) {
      return null;
    }

    final fieldPath = path.field(key);
    final fieldValue = value[key];
    if (fieldValue is! JsonObject) {
      diagnostics.reportTypeMismatch(path: fieldPath, expected: 'object', actual: fieldValue);
      return null;
    }
    return JsonObjectReader(value: fieldValue, path: fieldPath, diagnostics: diagnostics);
  }

  /// Reads an optional object array and skips malformed elements.
  List<JsonObjectReader> optionalObjectList(String key) {
    if (!value.containsKey(key)) {
      return const [];
    }

    final fieldPath = path.field(key);
    final fieldValue = value[key];
    if (fieldValue is! JsonArray) {
      diagnostics.reportTypeMismatch(path: fieldPath, expected: 'array', actual: fieldValue);
      return const [];
    }

    final result = <JsonObjectReader>[];
    for (final (index, element) in fieldValue.indexed) {
      final elementPath = fieldPath.index(index);
      if (element is! JsonObject) {
        diagnostics.reportTypeMismatch(path: elementPath, expected: 'object', actual: element);
        continue;
      }
      result.add(JsonObjectReader(value: element, path: elementPath, diagnostics: diagnostics));
    }
    return result;
  }

  /// Reads an optional string array and skips malformed elements.
  List<String> optionalStringList(String key) {
    if (!value.containsKey(key)) {
      return const [];
    }

    final fieldPath = path.field(key);
    final fieldValue = value[key];
    if (fieldValue is! JsonArray) {
      diagnostics.reportTypeMismatch(path: fieldPath, expected: 'array', actual: fieldValue);
      return const [];
    }

    final result = <String>[];
    for (final (index, element) in fieldValue.indexed) {
      if (element is! String) {
        diagnostics.reportTypeMismatch(
          path: fieldPath.index(index),
          expected: 'string',
          actual: element,
        );
        continue;
      }
      result.add(element);
    }
    return result;
  }

  /// Reports fields that are not included in [allowed].
  void reportUnknownFields(Set<String> allowed) {
    for (final key in value.keys) {
      if (!allowed.contains(key)) {
        diagnostics.warning(
          code: _unknownFieldCode,
          path: path.field(key),
          message: 'Unknown field.',
        );
      }
    }
  }
}
