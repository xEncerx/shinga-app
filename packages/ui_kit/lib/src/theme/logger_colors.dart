import 'package:flutter/material.dart';

/// A theme extension for log entry colors used in the logger screen.
@immutable
class LoggerColors extends ThemeExtension<LoggerColors> {
  /// Creates a [LoggerColors] instance.
  const LoggerColors({
    required this.error,
    required this.critical,
    required this.info,
    required this.debug,
    required this.verbose,
    required this.warning,
    required this.exception,
    required this.httpError,
    required this.httpRequest,
    required this.httpResponse,
    required this.blocEvent,
    required this.blocTransition,
    required this.blocClose,
    required this.blocCreate,
    required this.route,
  });

  /// The color for error log entries.
  final Color error;

  /// The color for critical log entries.
  final Color critical;

  /// The color for info log entries.
  final Color info;

  /// The color for debug log entries.
  final Color debug;

  /// The color for verbose log entries.
  final Color verbose;

  /// The color for warning log entries.
  final Color warning;

  /// The color for exception log entries.
  final Color exception;

  /// The color for HTTP error log entries.
  final Color httpError;

  /// The color for HTTP request log entries.
  final Color httpRequest;

  /// The color for HTTP response log entries.
  final Color httpResponse;

  /// The color for BLoC event log entries.
  final Color blocEvent;

  /// The color for BLoC transition log entries.
  final Color blocTransition;

  /// The color for BLoC close log entries.
  final Color blocClose;

  /// The color for BLoC create log entries.
  final Color blocCreate;

  /// The color for route log entries.
  final Color route;

  /// The light theme log color palette.
  static const light = LoggerColors(
    error: Color(0xFFDC3734),
    critical: Color(0xFFC62828),
    info: Color(0xFF217AC3),
    debug: Color(0xFF807373),
    verbose: Color(0xFF807373),
    warning: Color(0xFFC25700),
    exception: Color(0xFFDC3734),
    httpError: Color(0xFFDC3734),
    httpRequest: Color(0xFFDC00AD),
    httpResponse: Color(0xFF078A14),
    blocEvent: Color(0xFF278285),
    blocTransition: Color(0xFF208753),
    blocClose: Color(0xFFEA0057),
    blocCreate: Color(0xFF39863F),
    route: Color(0xFF9E44F9),
  );

  /// The dark theme log color palette.
  static const dark = LoggerColors(
    error: Color(0xFFEF5350),
    critical: Color(0xFFC62828),
    info: Color(0xFF42A5F5),
    debug: Color(0xFF9E9E9E),
    verbose: Color(0xFFBDBDBD),
    warning: Color(0xFFEF6C00),
    exception: Color(0xFFEF5350),
    httpError: Color(0xFFEF5350),
    httpRequest: Color(0xFFF602C1),
    httpResponse: Color(0xFF26FF3C),
    blocEvent: Color(0xFF63FAFE),
    blocTransition: Color(0xFF56FEA8),
    blocClose: Color(0xFFFF005F),
    blocCreate: Color(0xFF78E681),
    route: Color(0xFFAF5FFF),
  );

  @override
  ThemeExtension<LoggerColors> copyWith({
    Color? error,
    Color? critical,
    Color? info,
    Color? debug,
    Color? verbose,
    Color? warning,
    Color? exception,
    Color? httpError,
    Color? httpRequest,
    Color? httpResponse,
    Color? blocEvent,
    Color? blocTransition,
    Color? blocClose,
    Color? blocCreate,
    Color? route,
  }) {
    return LoggerColors(
      error: error ?? this.error,
      critical: critical ?? this.critical,
      info: info ?? this.info,
      debug: debug ?? this.debug,
      verbose: verbose ?? this.verbose,
      warning: warning ?? this.warning,
      exception: exception ?? this.exception,
      httpError: httpError ?? this.httpError,
      httpRequest: httpRequest ?? this.httpRequest,
      httpResponse: httpResponse ?? this.httpResponse,
      blocEvent: blocEvent ?? this.blocEvent,
      blocTransition: blocTransition ?? this.blocTransition,
      blocClose: blocClose ?? this.blocClose,
      blocCreate: blocCreate ?? this.blocCreate,
      route: route ?? this.route,
    );
  }

  @override
  ThemeExtension<LoggerColors> lerp(ThemeExtension<LoggerColors>? other, double t) {
    if (other is! LoggerColors) return this;
    return LoggerColors(
      error: Color.lerp(error, other.error, t)!,
      critical: Color.lerp(critical, other.critical, t)!,
      info: Color.lerp(info, other.info, t)!,
      debug: Color.lerp(debug, other.debug, t)!,
      verbose: Color.lerp(verbose, other.verbose, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      exception: Color.lerp(exception, other.exception, t)!,
      httpError: Color.lerp(httpError, other.httpError, t)!,
      httpRequest: Color.lerp(httpRequest, other.httpRequest, t)!,
      httpResponse: Color.lerp(httpResponse, other.httpResponse, t)!,
      blocEvent: Color.lerp(blocEvent, other.blocEvent, t)!,
      blocTransition: Color.lerp(blocTransition, other.blocTransition, t)!,
      blocClose: Color.lerp(blocClose, other.blocClose, t)!,
      blocCreate: Color.lerp(blocCreate, other.blocCreate, t)!,
      route: Color.lerp(route, other.route, t)!,
    );
  }
}
