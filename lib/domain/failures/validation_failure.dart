import 'package:shinga/domain/failures/app_failure.dart';

/// The base sealed class for input validation failures.
sealed class ValidationFailure extends AppFailure {
  /// Creates a [ValidationFailure] with the given [code].
  const ValidationFailure({required super.code, super.details});
}

/// Failure when the request body fails server-side validation.
///
/// The [details] field may contain field-level validation messages.
final class ValidationErrorFailure extends ValidationFailure {
  /// Creates a [ValidationErrorFailure].
  const ValidationErrorFailure({super.code = 'ValidationError', super.details});
}
