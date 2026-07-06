import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// The settings shell page that contains nested settings routes.
@RoutePage()
class SettingsPage extends StatelessWidget {
  /// Creates a [SettingsPage] widget.
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AutoRouter();
  }
}
