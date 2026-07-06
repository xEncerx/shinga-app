/// Default border radius values used across the application.
///
/// Use these constants instead of hardcoded numeric values to ensure
/// visual consistency. The scale is derived from common UI patterns in
/// the design system.
abstract final class AppRadius {
  /// Micro radius value (1pt).
  ///
  /// Used for tiny elements such as text cursors or carets.
  static const micro = 1.0;

  /// Extra small radius value (2pt).
  static const xs = 2.0;

  /// Small radius value (4pt).
  static const s = 4.0;

  /// Medium radius value (10pt).
  static const m = 10.0;

  /// Large radius value (12pt).
  static const l = 12.0;

  /// Extra large radius value (14pt).
  static const xl = 14.0;

  /// 2x extra large radius value (16pt).
  static const xxl = 16.0;

  /// 3x extra large radius value (18pt).
  static const xxxl = 18.0;

  /// Full radius value (99pt).
  static const full = 99.0;

  /// Default button radius value (12pt).
  static const double button = l;

  /// Default card radius value (14pt).
  static const double card = xl;

  /// Default chip radius value (10pt).
  static const double chip = m;

  /// Default application radius value (16pt).
  static const double defaultR = xxl;
}
