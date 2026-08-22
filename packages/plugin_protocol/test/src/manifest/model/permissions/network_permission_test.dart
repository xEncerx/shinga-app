import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('NetworkPermission', () {
    test('keeps an immutable defensive copy of hosts', () {
      final hosts = <NetworkHostPattern>[
        NetworkHostPattern.tryParse('api.example.com')!,
      ];
      final permission = NetworkPermission(hosts: hosts);

      hosts.clear();

      expect(permission.hosts, hasLength(1));
      expect(permission.hosts.clear, throwsUnsupportedError);
    });

    test('allows an empty host list to represent no reachable hosts', () {
      final permission = NetworkPermission(hosts: const []);

      expect(permission.hosts, isEmpty);
    });
  });
}
