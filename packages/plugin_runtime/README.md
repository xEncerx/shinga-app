# Shinga Plugin Runtime

Provides bounded access to plugin packages, manifest loading, static package
validation, immutable executable artifacts, runtime contracts, compatibility
checks, installation policy, and a reusable package inspector.

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

Inspection reads every reachable Dart module once through the stable bounded
reader, rejects BOM/NUL/malformed UTF-8 and forbidden imports, and retains the
exact bytes and normalized in-memory module IDs. A valid package therefore
executes without re-reading the filesystem.

This package is engine-neutral. It owns invocation limits, cancellation,
generic host-operation contracts, and no-queue admission, but does not import
D4rt. The opt-in `plugin_runtime_d4rt` package owns worker isolates and the
interpreter adapter.
