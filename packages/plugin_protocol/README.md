# Shinga Plugin Protocol

Pure Dart models, diagnostics, and parsing for the versioned Shinga plugin
manifest format.

```dart
final result = PluginManifestParser().parse(source);
if (result.isSuccess) {
  final manifest = result.manifest!;
  print('${manifest.id} targets Plugin API ${manifest.pluginApiVersion}');
}
```

Manifest parsing validates the source format but intentionally does not decide
whether `pluginApiVersion` is supported by a particular runtime.

See [Plugin Manifest v1](docs/plugin-manifest-v1.md) for the normative schema.
