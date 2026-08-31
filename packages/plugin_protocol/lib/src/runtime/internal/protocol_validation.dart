import 'dart:convert';

import 'package:plugin_protocol/src/runtime/plugin_error.dart';
import 'package:plugin_protocol/src/runtime/plugin_protocol_limits.dart';

/// Validates a stable identifier for use in plugin protocol messages.
void validateIdentifier(
  String value,
  String code, {
  int maxBytes = PluginProtocolLimits.maxIdentifierBytes,
}) {
  if (value.isEmpty ||
      utf8.encode(value).length > maxBytes ||
      value.codeUnits.any((unit) => unit < 0x20 || unit == 0x7f)) {
    throw PluginProtocolException(code);
  }
}
