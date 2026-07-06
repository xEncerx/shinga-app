import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';
import 'package:webview_guardian/webview_guardian.dart';

/// An observer for monitoring ad blocker events and errors, logging them using Talker.
class AdBlockerObserver implements WebViewObserver {
  /// Creates an [AdBlockerObserver] instance.
  AdBlockerObserver(this._logger);

  final Talker _logger;

  @override
  void onError(WebViewError error) => _logger.error('[AdBlocker] ${error.message}', error.cause);

  @override
  void onEvent(WebViewEvent event) {
    switch (event) {
      case FilterListFetchStarted():
        _logger.info('[AdBlocker]: Filter list fetch started for ${event.url}');
      case EngineCompiled():
        _logger.info(
          '[AdBlocker] Engine compiled in ${event.compilationTime.inMilliseconds} ms with ${event.totalRules} rules',
        );
      case EngineRestoredFromCache():
        _logger.info(
          '[AdBlocker] Engine restored from cache in ${event.compilationTime.inMilliseconds} ms with ${event.totalRules} rules',
        );
      case FilterCacheCleared():
        _logger.info('[AdBlocker] Filter cache cleared');
      case FilterCacheMatch():
        _logger.info('[AdBlocker] Cache HIT for ${event.url}');
      case RequestBlocked():
        if (kDebugMode) {
          _logger.debug('[AdBlocker] Blocked request to ${event.url}');
        }
      case RequestAllowed():
        if (kDebugMode) {
          _logger.debug('[AdBlocker] Allowed request to ${event.url}');
        }
      case ScriptletInjected():
        if (kDebugMode) {
          _logger.debug(
            '[AdBlocker] Injected scriptlet ${event.scriptletName} into ${event.hostname}',
          );
        }
      case CosmeticCssInjected():
        if (kDebugMode) {
          _logger.debug(
            '[AdBlocker] Injected cosmetic CSS for ${event.hostname} with selector ${event.selector}',
          );
        }
    }
  }
}
