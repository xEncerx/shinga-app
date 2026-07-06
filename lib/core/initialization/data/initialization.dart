import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shinga/core/initialization/data/initialize_dependencies.dart';
import 'package:shinga/core/initialization/model/dependencies.dart';

Future<Dependencies>? _$initializeApp;

/// Initializes the application and its dependencies.
Future<Dependencies> $initializeApp({
  void Function(int progress, String message)? onProgress,
  FutureOr<void> Function(Dependencies dependencies)? onSuccess,
  void Function(Object error, StackTrace stackTrace)? onError,
}) => _$initializeApp ??= Future<Dependencies>(() async {
  late final WidgetsBinding binding;
  try {
    binding = WidgetsFlutterBinding.ensureInitialized()..deferFirstFrame();

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      onError?.call(error, stackTrace);
      return true;
    };
    FlutterError.onError = (details) {
      onError?.call(details.exception, details.stack ?? StackTrace.current);
    };

    final dependencies = await $initializeDependencies(
      onProgress: onProgress,
    ).timeout(const Duration(minutes: 1));

    await onSuccess?.call(dependencies);
    return dependencies;
  } on Object catch (error, stackTrace) {
    onError?.call(error, stackTrace);
    rethrow;
  } finally {
    binding.addPostFrameCallback((_) => binding.allowFirstFrame());
    _$initializeApp = null;
  }
});
