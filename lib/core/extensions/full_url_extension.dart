import '../core.dart';

extension UrlExtension on String {
  /// Returns the full URL for the image path.
  String get fullUrl => ApiConstants.baseUrl + this;
}
