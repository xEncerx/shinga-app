import 'package:plugin_protocol/plugin_protocol.dart';

/// Whether [value] is a portable package-relative POSIX path.
bool isSafePackagePath(String value) => isPortablePluginPackagePath(value);
