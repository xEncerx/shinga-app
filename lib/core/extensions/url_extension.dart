import 'package:shinga/core/core.dart';

/// Extension on String to convert relative URLs to absolute URLs.
extension UrlExtension on String {
  static const String _baseUrl = Settings.baseUrl;

  /// Converts a relative URL to an absolute URL by prepending the base URL if necessary.
  String toAbsoluteUrl() {
    if (startsWith('http')) {
      return this;
    }

    final baseEndsWithSlash = _baseUrl.endsWith('/');
    final pathStartsWithSlash = startsWith('/');

    if (baseEndsWithSlash && pathStartsWithSlash) {
      return '$_baseUrl${substring(1)}';
    } else if (!baseEndsWithSlash && !pathStartsWithSlash) {
      return '$_baseUrl/$this';
    }
    return '$_baseUrl$this';
  }
}
