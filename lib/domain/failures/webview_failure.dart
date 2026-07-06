import 'package:shinga/domain/domain.dart';

sealed class WebViewFailure extends AppFailure {
  const WebViewFailure({required super.code, super.details});
}

final class FilterFetchFailure extends WebViewFailure {
  const FilterFetchFailure({super.code = 'FilterFetchFailure', super.details});
}

final class CacheRestoreFailure extends WebViewFailure {
  const CacheRestoreFailure({super.code = 'CacheRestoreFailure', super.details});
}

final class EngineBuildFailure extends WebViewFailure {
  const EngineBuildFailure({super.code = 'EngineBuildFailure', super.details});
}

final class EngineInitFailure extends WebViewFailure {
  const EngineInitFailure({super.code = 'EngineInitFailure', super.details});
}

final class WebViewIsolateCrashFailure extends WebViewFailure {
  const WebViewIsolateCrashFailure({super.code = 'WebViewIsolateCrashFailure', super.details});
}
