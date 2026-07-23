import 'package:shinga/domain/domain.dart';

/// Base failure for WebView and ad-blocking infrastructure errors.
sealed class WebViewFailure extends AppFailure {
  /// Creates a WebView failure with a stable [code] and optional [details].
  const WebViewFailure({required super.code, super.details});
}

/// Indicates that a remote ad-blocking filter could not be fetched.
final class FilterFetchFailure extends WebViewFailure {
  /// Creates a filter fetch failure.
  const FilterFetchFailure({super.code = 'FilterFetchFailure', super.details});
}

/// Indicates that the cached ad-blocking state could not be restored.
final class CacheRestoreFailure extends WebViewFailure {
  /// Creates a cache restoration failure.
  const CacheRestoreFailure({super.code = 'CacheRestoreFailure', super.details});
}

/// Indicates that the ad-blocking engine could not be built.
final class EngineBuildFailure extends WebViewFailure {
  /// Creates an engine build failure.
  const EngineBuildFailure({super.code = 'EngineBuildFailure', super.details});
}

/// Indicates that the ad-blocking engine could not be initialized.
final class EngineInitFailure extends WebViewFailure {
  /// Creates an engine initialization failure.
  const EngineInitFailure({super.code = 'EngineInitFailure', super.details});
}

/// Indicates that the WebView processing isolate terminated unexpectedly.
final class WebViewIsolateCrashFailure extends WebViewFailure {
  /// Creates a WebView isolate crash failure.
  const WebViewIsolateCrashFailure({super.code = 'WebViewIsolateCrashFailure', super.details});
}
