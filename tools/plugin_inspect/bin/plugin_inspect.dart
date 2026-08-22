import 'dart:io';

import 'package:plugin_inspect/plugin_inspect.dart';

/// Runs the plugin package inspector command.
Future<void> main(List<String> arguments) async {
  exitCode = await runPluginInspect(arguments);
}
