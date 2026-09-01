part of '../../execution/plugin_executable_artifact.dart';

/// Validates generic entry constraints before adapter-owned source preflight.
final class PluginPackageValidator {
  /// Creates a language-independent package validator.
  const PluginPackageValidator();

  /// Validates [manifest] and delegates source inspection to [adapter].
  Future<PackageValidationResult> validate(
    PluginPackageReader package,
    PluginManifest manifest,
    PluginRuntimeAdapter adapter, {
    required int wireProtocolVersion,
  }) async {
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

    try {
      if (await package.refersToSameEntry(PluginPackageFormat.manifestPath, entryPath)) {
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

    if (diagnostics.hasErrors) {
      return PackageValidationResult(diagnostics: diagnostics);
    }
    final PluginArtifactBuildResult artifactResult;
    try {
      artifactResult = await adapter.inspect(package, manifest);
    } on Object {
      diagnostics.add(_invalidAdapterOutputDiagnostic(entryPath, manifestPath));
      return PackageValidationResult(diagnostics: diagnostics);
    }
    diagnostics.addAll(
      artifactResult.diagnostics.map(
        (diagnostic) => _entryDiagnostic(diagnostic, entryPath, manifestPath),
      ),
    );
    if (diagnostics.hasErrors) {
      return PackageValidationResult(diagnostics: diagnostics);
    }
    final candidate = artifactResult.candidate;
    final String adapterId;
    try {
      adapterId = adapter.id;
    } on Object {
      diagnostics.add(_invalidAdapterOutputDiagnostic(entryPath, manifestPath));
      return PackageValidationResult(diagnostics: diagnostics);
    }
    if (candidate == null || adapterId.isEmpty) {
      diagnostics.add(_invalidAdapterOutputDiagnostic(entryPath, manifestPath));
      return PackageValidationResult(diagnostics: diagnostics);
    }
    final sourceBytes = candidate.copySourceBytes();
    if (!_validCandidateSources(sourceBytes, entryPath)) {
      diagnostics.add(_invalidAdapterOutputDiagnostic(entryPath, manifestPath));
      return PackageValidationResult(diagnostics: diagnostics);
    }
    final artifact = _mintPluginExecutableArtifact(
      manifest: manifest,
      adapterId: adapterId,
      wireProtocolVersion: wireProtocolVersion,
      sourceBytes: sourceBytes,
    );
    return PackageValidationResult(
      diagnostics: diagnostics,
      artifact: artifact,
    );
  }

  PackageDiagnostic _invalidAdapterOutputDiagnostic(
    String entryPath,
    JsonPath manifestPath,
  ) {
    return PackageDiagnostic.error(
      code: 'plugin.entry.adapter_output_invalid',
      message: 'Runtime adapter produced invalid inspection output.',
      relativePath: entryPath,
      manifestPath: manifestPath,
    );
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
      PluginPackageReadFailure.tooLarge => PackageDiagnostic.error(
        code: 'plugin.entry.too_large',
        message: 'Entry file exceeds the adapter source limit.',
        relativePath: entryPath,
        manifestPath: manifestPath,
      ),
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
      PluginPackageReadFailure.changedDuringRead => PackageDiagnostic.error(
        code: 'plugin.entry.changed_during_read',
        message: 'Entry file "$entryPath" changed while it was being read.',
        relativePath: entryPath,
        manifestPath: manifestPath,
      ),
      PluginPackageReadFailure.pathCaseMismatch => PackageDiagnostic.error(
        code: 'plugin.entry.path_case_mismatch',
        message: 'Entry path must match exact on-disk casing.',
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

  PackageDiagnostic _entryDiagnostic(
    PackageDiagnostic diagnostic,
    String entryPath,
    JsonPath manifestPath,
  ) {
    if (diagnostic.relativePath != entryPath) return diagnostic;
    return switch (diagnostic.code) {
      'plugin.source.module_missing' => PackageDiagnostic.error(
        code: 'plugin.entry.missing',
        message: 'Entry file "$entryPath" does not exist.',
        relativePath: entryPath,
        manifestPath: manifestPath,
      ),
      'plugin.source.module_not_file' => PackageDiagnostic.error(
        code: 'plugin.entry.not_file',
        message: 'Entry path must identify a regular file.',
        relativePath: entryPath,
        manifestPath: manifestPath,
      ),
      'plugin.source.module_too_large' => PackageDiagnostic.error(
        code: 'plugin.entry.too_large',
        message: diagnostic.message,
        relativePath: entryPath,
        manifestPath: manifestPath,
      ),
      'plugin.source.module_symbolic_link_forbidden' => PackageDiagnostic.error(
        code: 'plugin.entry.symbolic_link_forbidden',
        message: 'Entry file must not be a symbolic link.',
        relativePath: entryPath,
        manifestPath: manifestPath,
      ),
      'plugin.source.module_changed_during_read' => PackageDiagnostic.error(
        code: 'plugin.entry.changed_during_read',
        message: 'Entry file "$entryPath" changed while it was being read.',
        relativePath: entryPath,
        manifestPath: manifestPath,
      ),
      'plugin.source.module_path_case_mismatch' => PackageDiagnostic.error(
        code: 'plugin.entry.path_case_mismatch',
        message: 'Entry path must match exact on-disk casing.',
        relativePath: entryPath,
        manifestPath: manifestPath,
      ),
      'plugin.source.module_unreadable' => PackageDiagnostic.error(
        code: 'plugin.entry.unreadable',
        message: 'Entry file "$entryPath" could not be read.',
        relativePath: entryPath,
        manifestPath: manifestPath,
      ),
      _ => diagnostic,
    };
  }
}

bool _validCandidateSources(Map<String, Uint8List> sourceBytes, String entryPath) {
  if (sourceBytes.isEmpty || !sourceBytes.containsKey(entryPath)) return false;
  final caseFoldedPaths = <String>{};
  for (final path in sourceBytes.keys) {
    if (!isPortablePluginPackagePath(path)) return false;
    if (!caseFoldedPaths.add(path.toLowerCase())) return false;
  }
  return true;
}
