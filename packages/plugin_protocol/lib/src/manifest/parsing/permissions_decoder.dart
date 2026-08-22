import 'package:plugin_protocol/src/common/common.dart';
import 'package:plugin_protocol/src/manifest/models/models.dart';

const DiagnosticCode _unknownPermissionCode = 'manifest.permissions.unknown';
const DiagnosticCode _invalidHostPatternCode = 'manifest.permissions.network.host.invalid';
const DiagnosticCode _duplicateHostPatternCode = 'manifest.permissions.network.host.duplicate';

/// Decodes plugin permissions, treating a missing object as no permissions.
PluginPermissions? decodePermissions(
  JsonObjectReader? reader,
  DiagnosticCollector diagnostics,
) {
  if (reader == null) {
    return const PluginPermissions();
  }

  final initialDiagnosticCount = diagnostics.diagnostics.length;
  final valueReader = JsonObjectReader(
    value: reader.value,
    path: reader.path,
    diagnostics: diagnostics,
  );

  for (final permission in reader.value.keys) {
    if (permission != 'network') {
      diagnostics.error(
        code: _unknownPermissionCode,
        path: reader.path.field(permission),
        message: 'Unknown permission "$permission".',
      );
    }
  }

  NetworkPermission? network;
  if (reader.value.containsKey('network')) {
    final networkReader = valueReader.optionalObject('network');
    if (networkReader != null) {
      network = _decodeNetworkPermission(networkReader, diagnostics);
    }
  }

  if (diagnostics.hasErrorsSince(initialDiagnosticCount)) {
    return null;
  }
  return PluginPermissions(network: network);
}

NetworkPermission _decodeNetworkPermission(
  JsonObjectReader reader,
  DiagnosticCollector diagnostics,
) {
  final hostsPath = reader.path.field('hosts');
  final hosts = <NetworkHostPattern>[];
  final uniquePatterns = <NetworkHostPattern>{};

  if (!reader.value.containsKey('hosts')) {
    diagnostics.reportMissingField(hostsPath);
  } else {
    final rawHosts = reader.value['hosts'];
    if (rawHosts is! JsonArray) {
      diagnostics.reportTypeMismatch(
        path: hostsPath,
        expected: 'array',
        actual: rawHosts,
      );
    } else {
      for (final (index, rawHost) in rawHosts.indexed) {
        final hostPath = hostsPath.index(index);
        if (rawHost is! String) {
          diagnostics.reportTypeMismatch(
            path: hostPath,
            expected: 'string',
            actual: rawHost,
          );
          continue;
        }

        final pattern = NetworkHostPattern.tryParse(rawHost);
        if (pattern == null) {
          diagnostics.error(
            code: _invalidHostPatternCode,
            path: hostPath,
            message: 'Invalid network host pattern "$rawHost".',
          );
          continue;
        }
        if (!uniquePatterns.add(pattern)) {
          diagnostics.error(
            code: _duplicateHostPatternCode,
            path: hostPath,
            message: 'Network host pattern "$pattern" is duplicated.',
          );
          continue;
        }
        hosts.add(pattern);
      }
    }
  }

  reader.reportUnknownFields(const {'hosts'});
  return NetworkPermission(hosts: hosts);
}
