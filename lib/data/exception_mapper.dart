import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shinga/data/models/api_error_dto.dart';
import 'package:shinga/domain/failures/failures.dart';
import 'package:storage/storage.dart';
import 'package:webview_guardian/webview_guardian.dart';

/// Maps infrastructure exceptions to [AppFailure] and wraps async calls
/// in [Either], keeping repositories free of try/catch boilerplate.
///
/// Usage in a repository method:
/// ```dart
/// Future<Either<AppFailure, User>> login(Credentials c) =>
///     ExceptionMapper.guard(() => _remote.login(c.toDto()));
/// ```
abstract final class ExceptionMapper {
  /// Executes [call] and maps any thrown exception to [Left<AppFailure>].
  ///
  /// Returns [Right<T>] on success, [Left<AppFailure>] on failure.
  static Future<Either<AppFailure, T>> guard<T>(
    Future<T> Function() call,
  ) async {
    try {
      return Right(await call());
    } on DioException catch (e) {
      return Left(_fromDioException(e));
    } on SocketException {
      return const Left(NoInternetFailure());
    } on StorageException catch (e) {
      return Left(_fromStorageException(e));
    } on Exception catch (e) {
      return Left(UnknownNetworkFailure(details: e.toString()));
    }
  }

  static AppFailure _fromDioException(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const ConnectionTimeoutFailure(),
      DioExceptionType.connectionError => const NoInternetFailure(),
      _ => _fromResponse(e.response),
    };
  }

  static AppFailure _fromStorageException(StorageException e) {
    return switch (e) {
      StorageReadException() => const StorageReadFailure(),
      StorageWriteException() => const StorageWriteFailure(),
      StorageDeleteException() => const StorageDeleteFailure(),
      _ => UnknownStorageFailure(details: e.message),
    };
  }

  static AppFailure fromWebViewError(WebViewError e) {
    return switch (e) {
      FilterFetchFailed() => const FilterFetchFailure(),
      CacheRestoreFailed() => const CacheRestoreFailure(),
      EngineBuildFailed() => const EngineBuildFailure(),
      EngineInitFailed() => const EngineInitFailure(),
      IsolateCrashError() => const WebViewIsolateCrashFailure(),
    };
  }

  static AppFailure _fromResponse(Response<dynamic>? response) {
    if (response == null) return const UnknownNetworkFailure();
    final dto = _tryParseDto(response);

    if (dto != null) {
      return _fromErrorCode(dto.error, dto.statusCode, dto.details);
    }

    return _fromStatusCode(response.statusCode ?? 0);
  }

  /// Maps a string error code returned by the API to a specific [AppFailure].
  ///
  /// If the code is not recognised, falls back to [_fromStatusCode] while
  /// preserving the original API [errorCode] on the failure.
  static AppFailure _fromErrorCode(
    String errorCode,
    int statusCode,
    List<String> details,
  ) {
    final detailsStr = details.isNotEmpty ? details.join('\n') : null;
    return switch (errorCode) {
      // Auth
      'MissingCredentials' => MissingCredentialsFailure(details: detailsStr),
      'InvalidCredentials' => InvalidCredentialsFailure(details: detailsStr),
      'InvalidTokenCredentials' => InvalidTokenCredentialsFailure(details: detailsStr),
      // Verification
      'VerificationCodeNotFound' => VerificationCodeNotFoundFailure(details: detailsStr),
      'InvalidVerificationCode' => InvalidVerificationCodeFailure(details: detailsStr),
      // Resource
      'TitleNotFound' => TitleNotFoundFailure(details: detailsStr),
      'UserNotFound' => UserNotFoundFailure(details: detailsStr),
      'UserTitleNotFound' => UserTitleNotFoundFailure(details: detailsStr),
      // Conflict
      'UserAlreadyExists' => UserAlreadyExistsFailure(details: detailsStr),
      'UserTitleAlreadyExists' => UserTitleAlreadyExistsFailure(details: detailsStr),
      // Validation
      'ValidationError' => ValidationErrorFailure(details: detailsStr),
      // Server
      'InternalServerError' => ServerFailure(details: detailsStr),
      _ => _fromStatusCode(statusCode, details: detailsStr),
    };
  }

  /// Maps an HTTP [statusCode] to a specific [AppFailure].
  ///
  /// Falls back to [UnknownNetworkFailure] when code is not provided.
  static AppFailure _fromStatusCode(
    int statusCode, {
    String? details,
  }) {
    return switch (statusCode) {
      401 => UnauthorizedFailure(details: details),
      403 => ForbiddenFailure(details: details),
      404 => NotFoundFailure(details: details),
      429 => RateLimitFailure(details: details),
      >= 500 => ServerFailure(details: details),
      _ => UnknownNetworkFailure(details: details),
    };
  }

  static ApiErrorDto? _tryParseDto(Response<dynamic> response) {
    try {
      final data = response.data;
      if (data is Map<String, dynamic>) return ApiErrorDto.fromJson(data);
      return null;
    } on Exception catch (_) {
      return null;
    }
  }
}
