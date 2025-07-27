import 'package:flutter_svg/flutter_svg.dart';

/// Preloads SVG assets into cache for faster rendering.
///
/// Takes a list of asset paths and loads them into the SVG cache.
Future<void> preloadSVGs(List<String> assetsPaths) async {
  for (final path in assetsPaths) {
    final loader = SvgAssetLoader(path);
    await svg.cache.putIfAbsent(
      loader.cacheKey(null),
      () => loader.loadBytes(null),
    );
  }
}
