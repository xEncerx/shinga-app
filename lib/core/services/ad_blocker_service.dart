// core/services/localization_service.dart
// ignore_for_file: document_ignores

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:webview_guardian/webview_guardian.dart';

/// A service that manages the ad blocker functionality, including initialization and settings synchronization.
class AdBlockerService {
  /// Creates an [AdBlockerService] instance.
  AdBlockerService({
    required this._settingsRepository,
    required this._observer,
  });

  final AppSettingsRepository _settingsRepository;
  final WebViewObserver _observer;
  StreamSubscription<AppSettings>? _subscription;

  final _adBlocker = AdblockService();

  /// Initializes the ad blocker service and subscribes to settings changes.
  Future<AdblockService> initialize() async {
    final result = await _settingsRepository.getSettings();
    final appSettings = result.fold(
      (_) => AppSettings.defaults,
      (settings) => settings,
    );

    final subs = appSettings.adBlockerFilterSubscriptions
        .map((v) => FilterSubscription(url: v.url))
        .toList();

    _subscription = _settingsRepository.watchSettings().listen((settings) async {
      // If the ad blocker is not ready, we can't apply settings changes yet.
      if (!_adBlocker.isReady.value) return;

      // Update enabled state
      if (settings.isAdBlockerEnabled != _adBlocker.isEnabled) {
        _adBlocker.isEnabled = settings.isAdBlockerEnabled;
      }

      final subs = settings.adBlockerFilterSubscriptions
          .map((v) => FilterSubscription(url: v.url))
          .toList();

      // Update subscriptions if they have changed
      if (!listEquals(subs, _adBlocker.subscriptions)) {
        await _adBlocker.updateSubscriptions(subs);
      }
    });

    unawaited(
      _adBlocker.init(
        observer: _observer,
        observabilityOptions: const WebViewObservabilityOptions(
          // ignore: avoid_redundant_argument_values
          emitAllowedRequests: false,
          emitBlockedRequests: false,
          emitCosmeticInjections: false,
          emitScriptletInjections: false,
        ),
        subscriptions: subs,
      ),
    );

    return _adBlocker;
  }

  /// Disposes the subscription to settings changes.
  void dispose() => _subscription?.cancel();
}
