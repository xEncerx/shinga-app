import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shinga/core/core.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:ui_kit/ui_kit.dart';

/// A page that displays the logger screen for debugging purposes.
@RoutePage()
class LoggerPage extends StatelessWidget {
  /// Creates a [LoggerPage] widget.
  const LoggerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loggerColors = context.loggerColors;

    return TalkerScreen(
      talker: context.deps.logger,
      theme: TalkerScreenTheme.fromTheme(
        Theme.of(context),
        {
          // Base logs section
          TalkerKey.error: loggerColors.error,
          TalkerKey.critical: loggerColors.critical,
          TalkerKey.info: loggerColors.info,
          TalkerKey.debug: loggerColors.debug,
          TalkerKey.verbose: loggerColors.verbose,
          TalkerKey.warning: loggerColors.warning,
          TalkerKey.exception: loggerColors.exception,
          // Http section
          TalkerKey.httpError: loggerColors.httpError,
          TalkerKey.httpRequest: loggerColors.httpRequest,
          TalkerKey.httpResponse: loggerColors.httpResponse,
          // Bloc section
          TalkerKey.blocEvent: loggerColors.blocEvent,
          TalkerKey.blocTransition: loggerColors.blocTransition,
          TalkerKey.blocClose: loggerColors.blocClose,
          TalkerKey.blocCreate: loggerColors.blocCreate,
          // Flutter section
          TalkerKey.route: loggerColors.route,
        },
      ),
    );
  }
}
