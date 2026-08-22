import 'package:meta/meta.dart';

/// A normalized locale tag containing language, script, and region subtags.
@immutable
final class LocaleTag {
  const LocaleTag._({
    required this.language,
    required this.script,
    required this.region,
  });

  static final RegExp _languagePattern = RegExp(r'^[A-Za-z]{2,8}$');
  static final RegExp _scriptPattern = RegExp(r'^[A-Za-z]{4}$');
  static final RegExp _regionPattern = RegExp(r'^(?:[A-Za-z]{2}|[0-9]{3})$');

  /// The lowercase language subtag.
  final String language;

  /// The title-cased script subtag when declared.
  final String? script;

  /// The uppercase alphabetic or numeric region subtag when declared.
  final String? region;

  /// Creates a normalized locale tag when [source] is supported.
  static LocaleTag? tryParse(String source) {
    final parts = source.split('-');
    if (parts.isEmpty || !_languagePattern.hasMatch(parts.first)) {
      return null;
    }

    var index = 1;
    String? script;
    String? region;

    if (index < parts.length && _scriptPattern.hasMatch(parts[index])) {
      final rawScript = parts[index];
      script = '${rawScript[0].toUpperCase()}${rawScript.substring(1).toLowerCase()}';
      index++;
    }

    if (index < parts.length && _regionPattern.hasMatch(parts[index])) {
      region = parts[index].toUpperCase();
      index++;
    }

    if (index != parts.length) {
      return null;
    }

    return LocaleTag._(
      language: parts.first.toLowerCase(),
      script: script,
      region: region,
    );
  }

  /// Whether [source] can be represented by this locale model.
  static bool validate(String source) => tryParse(source) != null;

  @override
  bool operator ==(Object other) {
    return other is LocaleTag &&
        other.language == language &&
        other.script == script &&
        other.region == region;
  }

  @override
  int get hashCode => Object.hash(language, script, region);

  @override
  String toString() {
    return [language, ?script, ?region].join('-');
  }
}
