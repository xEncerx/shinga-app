import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/src/package/reader/reader.dart';
import 'package:plugin_runtime/src/package/validation/package_validation_result.dart';

/// Validates the files referenced by a parsed plugin manifest.
final class PluginPackageValidator {
  /// Creates a validator with a bounded JavaScript entry size.
  const PluginPackageValidator({
    this.maxEntryBytes = defaultMaxEntryBytes,
  }) : assert(maxEntryBytes >= 0, 'maxEntryBytes must not be negative.');

  /// The default maximum JavaScript entry size of 256 KiB.
  static const int defaultMaxEntryBytes = 256 * 1024;

  /// The maximum accepted JavaScript entry size in bytes.
  final int maxEntryBytes;

  /// Validates the entry declared by [manifest] against [package].
  Future<PackageValidationResult> validate(
    PluginPackageReader package,
    PluginManifest manifest,
  ) async {
    final diagnostics = <PackageDiagnostic>[];
    final entryPath = manifest.entry.value;
    final manifestPath = const JsonPath.root().field('entry');
    final PluginPackageEntry? entry;
    try {
      entry = await package.stat(entryPath);
    } on PluginPackageReadException catch (error) {
      diagnostics.add(_readFailureDiagnostic(error, manifestPath));
      return PackageValidationResult(diagnostics: diagnostics);
    }

    if (entry == null) {
      diagnostics.add(
        PackageDiagnostic.error(
          code: 'plugin.entry.missing',
          message: 'Entry file "$entryPath" does not exist.',
          relativePath: entryPath,
          manifestPath: manifestPath,
        ),
      );
      return PackageValidationResult(diagnostics: diagnostics);
    }
    if (entry.type == PluginPackageEntryType.symbolicLink) {
      diagnostics.add(
        PackageDiagnostic.error(
          code: 'plugin.entry.symbolic_link_forbidden',
          message: 'Entry file must not be a symbolic link.',
          relativePath: entryPath,
          manifestPath: manifestPath,
        ),
      );
      return PackageValidationResult(diagnostics: diagnostics);
    }
    if (entry.type != PluginPackageEntryType.file) {
      diagnostics.add(
        PackageDiagnostic.error(
          code: 'plugin.entry.not_file',
          message: 'Entry path must identify a regular file.',
          relativePath: entryPath,
          manifestPath: manifestPath,
        ),
      );
      return PackageValidationResult(diagnostics: diagnostics);
    }

    if (entry.size > maxEntryBytes) {
      diagnostics.add(_entryTooLarge(entryPath, manifestPath));
    }

    try {
      if (await package.refersToSameEntry(
        PluginPackageFormat.manifestPath,
        entryPath,
      )) {
        diagnostics.add(
          PackageDiagnostic.error(
            code: 'plugin.entry.same_as_manifest',
            message: 'Entry file must not refer to manifest.json.',
            relativePath: entryPath,
            manifestPath: manifestPath,
          ),
        );
      }
    } on PluginPackageReadException catch (error) {
      diagnostics.add(_readFailureDiagnostic(error, manifestPath));
    }

    if (entry.size <= maxEntryBytes) {
      try {
        await package.readBytes(entryPath, maxBytes: maxEntryBytes);
      } on PluginPackageReadException catch (error) {
        diagnostics.add(_readFailureDiagnostic(error, manifestPath));
      }
    }

    return PackageValidationResult(diagnostics: diagnostics);
  }

  PackageDiagnostic _readFailureDiagnostic(
    PluginPackageReadException error,
    JsonPath manifestPath,
  ) {
    final entryPath = error.relativePath;
    return switch (error.failure) {
      PluginPackageReadFailure.notFound => PackageDiagnostic.error(
        code: 'plugin.entry.missing',
        message: 'Entry file "$entryPath" does not exist.',
        relativePath: entryPath,
        manifestPath: manifestPath,
      ),
      PluginPackageReadFailure.notFile => PackageDiagnostic.error(
        code: 'plugin.entry.not_file',
        message: 'Entry path must identify a regular file.',
        relativePath: entryPath,
        manifestPath: manifestPath,
      ),
      PluginPackageReadFailure.tooLarge => _entryTooLarge(entryPath, manifestPath),
      PluginPackageReadFailure.symbolicLink => PackageDiagnostic.error(
        code: 'plugin.entry.symbolic_link_forbidden',
        message: 'Entry file must not be a symbolic link.',
        relativePath: entryPath,
        manifestPath: manifestPath,
      ),
      PluginPackageReadFailure.invalidPath ||
      PluginPackageReadFailure.outsidePackage => PackageDiagnostic.error(
        code: 'plugin.entry.outside_package',
        message: 'Entry path must remain inside the plugin package.',
        relativePath: entryPath,
        manifestPath: manifestPath,
      ),
      PluginPackageReadFailure.io => PackageDiagnostic.error(
        code: 'plugin.entry.unreadable',
        message: 'Entry file "$entryPath" could not be read.',
        relativePath: entryPath,
        manifestPath: manifestPath,
      ),
    };
  }

  PackageDiagnostic _entryTooLarge(String entryPath, JsonPath manifestPath) {
    return PackageDiagnostic.error(
      code: 'plugin.entry.too_large',
      message: 'Entry file must not exceed $maxEntryBytes bytes.',
      relativePath: entryPath,
      manifestPath: manifestPath,
    );
  }
}
