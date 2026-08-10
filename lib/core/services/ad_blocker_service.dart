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
  AppSettings _latestSettings = AppSettings.defaults;
  bool _isDisposed = false;

  final _adBlocker = AdblockService();

  /// Initializes the ad blocker service and subscribes to settings changes.
  Future<AdblockService> initialize() async {
    final result = await _settingsRepository.getSettings();
    final appSettings = result.fold(
      (_) => AppSettings.defaults,
      (settings) => settings,
    );
    _latestSettings = appSettings;
    _adBlocker.isEnabled = appSettings.isAdBlockerEnabled;

    final subs = appSettings.adBlockerFilterSubscriptions
        .map((v) => FilterSubscription(url: v.url))
        .toList();

    _subscription = _settingsRepository.watchSettings().listen((settings) async {
      _latestSettings = settings;
      if (_adBlocker.isReady.value) await _applySettings(settings);
    });

    unawaited(
      _adBlocker
          .init(
            observer: _observer,
            observabilityOptions: const WebViewObservabilityOptions(
              // ignore: avoid_redundant_argument_values
              emitAllowedRequests: false,
              emitBlockedRequests: false,
              emitCosmeticInjections: false,
              emitScriptletInjections: false,
            ),
            subscriptions: subs,
          )
          .then((_) => _isDisposed ? null : _applySettings(_latestSettings)),
    );

    return _adBlocker;
  }

  Future<void> _applySettings(AppSettings settings) async {
    if (settings.isAdBlockerEnabled != _adBlocker.isEnabled) {
      _adBlocker.isEnabled = settings.isAdBlockerEnabled;
    }

    final subscriptions = settings.adBlockerFilterSubscriptions
        .map((subscription) => FilterSubscription(url: subscription.url))
        .toList();
    if (!listEquals(subscriptions, _adBlocker.subscriptions)) {
      await _adBlocker.updateSubscriptions(subscriptions);
    }
  }

  /// Disposes the subscription to settings changes.
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _subscription?.cancel();
    _adBlocker.dispose();
  }
}
