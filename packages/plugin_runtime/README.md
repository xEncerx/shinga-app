# Shinga Plugin Runtime

Provides bounded access to plugin packages, manifest loading, static package
validation, runtime compatibility checks, installation policy, and a reusable
package inspector.

```dart
final parser = PluginManifestParser();
final inspector = PluginPackageInspector(
  manifestLoader: PluginManifestLoader(parser: parser),
  packageValidator: const PluginPackageValidator(),
  compatibilityPolicy: PluginCompatibilityPolicy(
    parser: parser,
    supportedPluginApiVersions: const {1},
  ),
);

final inspection = await inspector.inspect(
  DirectoryPluginPackageReader(Directory(pluginPath)),
);
```
