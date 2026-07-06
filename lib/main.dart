import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shinga/app/app.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

void main() => runZonedGuarded<void>(
  () async {
    // final progress = ValueNotifier<({int progress, String message})>(
    //   (progress: 0, message: ''),
    // );

    $initializeApp(
      // onProgress: (p, msg) => progress.value = (progress: p, message: msg),
      onSuccess: (deps) => runApp(
        InheritedDependencies(
          dependencies: deps,
          child: TranslationProvider(child: const MainApp()),
        ),
      ),
      onError: (error, stackTrace) => error is FlutterError
          ? null
          : runApp(
              MaterialApp(
                theme: AppTheme.lightTheme(),
                home: Scaffold(
                  body: Center(
                    child: SaStateMessage.error(
                      title: 'Init error occurred',
                      description: error.toString(),
                    ),
                  ),
                ),
              ),
            ),
    ).ignore();
  },
  (error, stack) => debugPrint('Zone error: $error\n$stack'),
);
