/// The base sealed class for all domain-level failures in the application.
///
/// Every failure carries a [code] that uniquely identifies the error type.
abstract class AppFailure {
  /// Creates an [AppFailure] with the given [code].
  const AppFailure({required this.code, this.details});

  /// The error code identifying the type of failure.
  ///
  /// Typically sourced from the API's `error` field or a fixed constant
  /// for client-side failures (e.g. `'ConnectionTimeout'`).
  final String code;

  /// Optional additional details about the failure, such as error messages or stack traces.
  final String? details;
}
