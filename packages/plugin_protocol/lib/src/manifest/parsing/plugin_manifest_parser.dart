import 'package:plugin_protocol/src/manifest/models/manifest_parse_result.dart';
import 'package:plugin_protocol/src/manifest/parsing/plugin_manifest_parser_impl.dart';

/// Parses plugin manifest source text into a normalized model.
abstract interface class PluginManifestParser {
  /// Creates the default plugin manifest parser.
  factory PluginManifestParser() = PluginManifestParserImpl;

  /// The manifest schema versions understood by this parser.
  Set<int> get supportedManifestVersions;

  /// Parses [source] without throwing for malformed user input.
  ManifestParseResult parse(String source);
}
