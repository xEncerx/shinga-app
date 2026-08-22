import 'package:plugin_protocol/plugin_protocol.dart';

/// The installation operation selected by policy.
enum PluginInstallOperation {
  /// Installs a plugin ID that is not currently present.
  install,

  /// Replaces an older installed version of the same plugin ID.
  update,
}

/// The result of evaluating a plugin manifest for installation.
final class PluginInstallPolicyResult {
  /// Creates an install policy result from defensive collection copies.
  PluginInstallPolicyResult({
    required this.operation,
    required List<NetworkHostPattern> addedNetworkHosts,
    required List<PluginDiagnostic> diagnostics,
  }) : addedNetworkHosts = List.unmodifiable(addedNetworkHosts),
       diagnostics = List.unmodifiable(diagnostics);

  /// The allowed operation, or `null` when installation was rejected.
  final PluginInstallOperation? operation;

  /// Network host grants not covered by the installed version.
  final List<NetworkHostPattern> addedNetworkHosts;

  /// All policy diagnostics in reporting order.
  final List<PluginDiagnostic> diagnostics;

  /// Whether policy permits continuing the installation flow.
  bool get isAllowed => operation != null && !hasErrors;

  /// Whether the user must approve newly requested network access.
  bool get requiresPermissionApproval => addedNetworkHosts.isNotEmpty;

  /// Whether at least one rejecting error was reported.
  bool get hasErrors => diagnostics.hasErrors;
}
