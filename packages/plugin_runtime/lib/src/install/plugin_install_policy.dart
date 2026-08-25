import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/src/compatibility/plugin_compatibility_policy.dart';
import 'package:plugin_runtime/src/install/installed_plugin_record.dart';
import 'package:plugin_runtime/src/install/installed_plugin_registry.dart';
import 'package:plugin_runtime/src/install/plugin_install_policy_result.dart';
import 'package:plugin_runtime/src/package/inspection/inspection.dart';

/// Evaluates compatibility, replacement, and permission installation policy.
final class PluginInstallPolicy {
  /// Creates an installation policy backed by [registry].
  const PluginInstallPolicy({
    required this.registry,
    required this.compatibility,
    this.allowNetworkPermission = true,
  });

  /// The installed plugin state provider.
  final InstalledPluginRegistry registry;

  /// The runtime compatibility policy applied before replacement checks.
  final PluginCompatibilityPolicy compatibility;

  /// Whether this host can grant the manifest v1 network permission.
  final bool allowNetworkPermission;

  /// Evaluates whether a structurally valid [package] may be installed or updated.
  Future<PluginInstallPolicyResult> validate(ValidPluginPackage package) async {
    final manifest = package.manifest;
    final diagnostics = <PluginDiagnostic>[];
    final compatibilityResult = compatibility.validate(manifest);
    diagnostics.addAll(compatibilityResult.diagnostics);

    final requestedNetwork = manifest.permissions.network;
    if (requestedNetwork != null && !allowNetworkPermission) {
      diagnostics.add(
        PackageDiagnostic(
          code: 'plugin.install.permission_unsupported',
          severity: DiagnosticSeverity.error,
          message: 'The network permission is not supported by this host.',
          manifestPath: const JsonPath.root().field('permissions').field('network'),
        ),
      );
    }

    final installed = await registry.find(manifest.id);
    final PluginInstallOperation operation;
    if (installed == null) {
      operation = PluginInstallOperation.install;
    } else {
      final precedence = manifest.version.compareTo(installed.version);
      if (manifest.version == installed.version) {
        diagnostics.add(
          PackageDiagnostic(
            code: 'plugin.install.duplicate',
            severity: DiagnosticSeverity.error,
            message: 'Plugin ${manifest.id} version ${manifest.version} is already installed.',
            manifestPath: const JsonPath.root().field('version'),
          ),
        );
      } else if (precedence < 0) {
        diagnostics.add(
          PackageDiagnostic(
            code: 'plugin.install.downgrade_forbidden',
            severity: DiagnosticSeverity.error,
            message:
                'Installed version ${installed.version} is newer than ${manifest.version}; downgrade is not allowed.',
            manifestPath: const JsonPath.root().field('version'),
          ),
        );
      } else if (precedence == 0) {
        diagnostics.add(
          PackageDiagnostic(
            code: 'plugin.install.version_not_newer',
            severity: DiagnosticSeverity.error,
            message:
                'Plugin version ${manifest.version} does not have higher SemVer precedence than ${installed.version}.',
            manifestPath: const JsonPath.root().field('version'),
          ),
        );
      }
      operation = PluginInstallOperation.update;
    }

    final addedHosts = _addedNetworkHosts(
      requested: requestedNetwork,
      installed: installed,
    );
    return PluginInstallPolicyResult(
      operation: diagnostics.hasErrors ? null : operation,
      addedNetworkHosts: addedHosts,
      diagnostics: diagnostics,
    );
  }

  List<NetworkHostPattern> _addedNetworkHosts({
    required NetworkPermission? requested,
    required InstalledPluginRecord? installed,
  }) {
    if (requested == null) return const [];

    final granted = installed?.permissions.network?.hosts ?? const [];
    return requested.hosts
        .where((pattern) => !granted.any((existing) => _covers(existing, pattern)))
        .toList(growable: false);
  }

  bool _covers(NetworkHostPattern granted, NetworkHostPattern requested) {
    if (granted == requested) return true;
    if (!granted.includeSubdomains) return false;
    if (requested.host == granted.host) return requested.includeSubdomains;
    return requested.host.endsWith('.${granted.host}');
  }
}
