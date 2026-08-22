import 'package:meta/meta.dart';
import 'package:plugin_protocol/src/manifest/models/permissions/network_host_pattern.dart';

/// Permission to access a fixed set of network hosts.
@immutable
final class NetworkPermission {
  /// Creates a network permission from a defensive copy of [hosts].
  NetworkPermission({required List<NetworkHostPattern> hosts}) : hosts = List.unmodifiable(hosts);

  /// The allowed host patterns in declaration order.
  final List<NetworkHostPattern> hosts;
}
