import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:test/test.dart';

void main() {
  test('defines the root manifest path', () {
    expect(PluginPackageFormat.manifestPath, 'manifest.json');
  });
}
