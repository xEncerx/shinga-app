import 'package:shinga/domain/failures/app_failure.dart';
import 'package:shinga/domain/failures/failure_message.dart';
import 'package:shinga/i18n/strings.g.dart';

/// Extension that maps an [AppFailure] to a localised [FailureMessage].
///
/// Uses the global [t] variable so it reads the current locale at call time.
/// Call this inside a widget's build method or a BLoC state consumer.
///
/// Example:
/// ```dart
/// final message = failure.toMessage();
/// showErrorDialog(title: message.title, body: message.description);
/// ```
extension AppFailureI18n on AppFailure {
  /// Returns a localized [FailureMessage] for this failure.
  FailureMessage toMessage() {
    final failures = t.failures;

    return switch (code) {
      // Network
      'ConnectionTimeout' => FailureMessage(
        title: failures.connectionTimeout.title,
        description: failures.connectionTimeout.description,
      ),
      'NoInternet' => FailureMessage(
        title: failures.noInternet.title,
        description: failures.noInternet.description,
      ),
      'UnknownNetworkError' => FailureMessage(
        title: failures.unknownNetworkError.title,
        description: failures.unknownNetworkError.description,
      ),
      'ServerError' || 'InternalServerError' => FailureMessage(
        title: failures.serverError.title,
        description: failures.serverError.description,
      ),
      'Unauthorized' => FailureMessage(
        title: failures.unauthorized.title,
        description: failures.unauthorized.description,
      ),
      'Forbidden' => FailureMessage(
        title: failures.forbidden.title,
        description: failures.forbidden.description,
      ),
      'NotFound' => FailureMessage(
        title: failures.notFound.title,
        description: failures.notFound.description,
      ),
      'RateLimit' => FailureMessage(
        title: failures.rateLimit.title,
        description: failures.rateLimit.description,
      ),
      // Auth
      'MissingCredentials' => FailureMessage(
        title: failures.missingCredentials.title,
        description: failures.missingCredentials.description,
      ),
      'InvalidCredentials' => FailureMessage(
        title: failures.invalidCredentials.title,
        description: failures.invalidCredentials.description,
      ),
      'InvalidTokenCredentials' => FailureMessage(
        title: failures.invalidTokenCredentials.title,
        description: failures.invalidTokenCredentials.description,
      ),
      // Verification
      'VerificationCodeNotFound' => FailureMessage(
        title: failures.verificationCodeNotFound.title,
        description: failures.verificationCodeNotFound.description,
      ),
      'InvalidVerificationCode' => FailureMessage(
        title: failures.invalidVerificationCode.title,
        description: failures.invalidVerificationCode.description,
      ),
      // Resource
      'TitleNotFound' => FailureMessage(
        title: failures.titleNotFound.title,
        description: failures.titleNotFound.description,
      ),
      'UserNotFound' => FailureMessage(
        title: failures.userNotFound.title,
        description: failures.userNotFound.description,
      ),
      'UserTitleNotFound' => FailureMessage(
        title: failures.userTitleNotFound.title,
        description: failures.userTitleNotFound.description,
      ),
      // Conflict
      'UserAlreadyExists' => FailureMessage(
        title: failures.userAlreadyExists.title,
        description: failures.userAlreadyExists.description,
      ),
      'UserTitleAlreadyExists' => FailureMessage(
        title: failures.userTitleAlreadyExists.title,
        description: failures.userTitleAlreadyExists.description,
      ),
      // Validation
      'ValidationError' => FailureMessage(
        title: failures.validationError.title,
        description: failures.validationError.description,
      ),
      'StorageReadFailure' => FailureMessage(
        title: failures.storageReadError.title,
        description: failures.storageReadError.description,
      ),
      'StorageWriteFailure' => FailureMessage(
        title: failures.storageWriteError.title,
        description: failures.storageWriteError.description,
      ),
      'StorageDeleteFailure' => FailureMessage(
        title: failures.storageDeleteError.title,
        description: failures.storageDeleteError.description,
      ),
      'FilterFetchFailure' => FailureMessage(
        title: failures.filterFetchFailure.title,
        description: failures.filterFetchFailure.description,
      ),
      'CacheRestoreFailure' => FailureMessage(
        title: failures.cacheRestoreFailure.title,
        description: failures.cacheRestoreFailure.description,
      ),
      'EngineBuildFailure' => FailureMessage(
        title: failures.engineBuildFailure.title,
        description: failures.engineBuildFailure.description,
      ),
      'EngineInitFailure' => FailureMessage(
        title: failures.engineInitFailure.title,
        description: failures.engineInitFailure.description,
      ),
      'WebViewIsolateCrashFailure' => FailureMessage(
        title: failures.webViewIsolateCrashFailure.title,
        description: failures.webViewIsolateCrashFailure.description,
      ),
      _ => FailureMessage(
        title: failures.unknown.title,
        description: failures.unknown.description,
      ),
    };
  }
}
