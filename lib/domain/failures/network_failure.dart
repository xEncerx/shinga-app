import 'package:shinga/domain/failures/app_failure.dart';

/// The base sealed class for all network-related failures.
sealed class NetworkFailure extends AppFailure {
  /// Creates a [NetworkFailure] with the given [code].
  const NetworkFailure({required super.code, super.details});
}

/// Failure when a connection attempt times out before a response is received.
final class ConnectionTimeoutFailure extends NetworkFailure {
  /// Creates a [ConnectionTimeoutFailure].
  const ConnectionTimeoutFailure({super.code = 'ConnectionTimeout', super.details});
}

/// Failure when no internet connection is available.
final class NoInternetFailure extends NetworkFailure {
  /// Creates a [NoInternetFailure].
  const NoInternetFailure({super.code = 'NoInternet', super.details});
}

/// Failure when the server returns an HTTP 403 Forbidden response.
final class ForbiddenFailure extends NetworkFailure {
  /// Creates a [ForbiddenFailure] with the API-provided [code] and optional details.
  const ForbiddenFailure({super.code = 'Forbidden', super.details});
}

/// Failure when the requested resource is not found (HTTP 404).
final class NotFoundFailure extends NetworkFailure {
  /// Creates a [NotFoundFailure] with the API-provided [code] and optional details.
  const NotFoundFailure({super.code = 'NotFound', super.details});
}

/// Failure when the client has exceeded the API rate limit (HTTP 429).
final class RateLimitFailure extends NetworkFailure {
  /// Creates a [RateLimitFailure] with the API-provided [code] and optional details.
  const RateLimitFailure({super.code = 'RateLimit', super.details});
}

/// Failure when the server responds with an HTTP 5xx error.
final class ServerFailure extends NetworkFailure {
  /// Creates a [ServerFailure] with the API-provided [code] and optional details.
  const ServerFailure({super.code = 'ServerError', super.details});
}

/// Failure for uncategorised or unexpected network errors.
final class UnknownNetworkFailure extends NetworkFailure {
  /// Creates an [UnknownNetworkFailure] with a default code and optional details.
  const UnknownNetworkFailure({super.code = 'UnknownNetworkError', super.details});
}
