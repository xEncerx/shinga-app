import 'dart:convert';

/// A segment identifying one part of a JSON path.
sealed class JsonPathSegment {
  const JsonPathSegment();

  void _writeTo(StringBuffer buffer);
}

/// A path identifying a value in a JSON document.
final class JsonPath {
  /// Creates a path pointing to the document root.
  const JsonPath.root() : segments = const [];

  const JsonPath._(this.segments);

  static final RegExp _fieldPattern = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

  /// The ordered segments following the document root.
  final List<JsonPathSegment> segments;

  /// Returns a path extended with [name].
  JsonPath field(String name) {
    return JsonPath._(
      List.unmodifiable(<JsonPathSegment>[...segments, _JsonFieldPathSegment(name)]),
    );
  }

  /// Returns a path extended with the array [index].
  JsonPath index(int index) {
    if (index < 0) {
      throw ArgumentError.value(index, 'index', 'must not be negative');
    }

    return JsonPath._(
      List.unmodifiable(<JsonPathSegment>[...segments, _JsonIndexPathSegment(index)]),
    );
  }

  /// Formats this path using JSONPath notation.
  @override
  String toString() {
    final buffer = StringBuffer(r'$');
    for (final segment in segments) {
      segment._writeTo(buffer);
    }
    return buffer.toString();
  }
}

final class _JsonFieldPathSegment extends JsonPathSegment {
  const _JsonFieldPathSegment(this.name);

  final String name;

  @override
  void _writeTo(StringBuffer buffer) {
    if (JsonPath._fieldPattern.hasMatch(name)) {
      buffer
        ..write('.')
        ..write(name);
      return;
    }

    buffer
      ..write('[')
      ..write(jsonEncode(name))
      ..write(']');
  }
}

final class _JsonIndexPathSegment extends JsonPathSegment {
  const _JsonIndexPathSegment(this.index);

  final int index;

  @override
  void _writeTo(StringBuffer buffer) {
    buffer
      ..write('[')
      ..write(index)
      ..write(']');
  }
}
