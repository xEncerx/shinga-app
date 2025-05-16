import 'package:flutter_svg/flutter_svg.dart';

Future<void> preloadSVGs(List<String> assetsPaths) async {
  for (final path in assetsPaths) {
    final loader = SvgAssetLoader(path);
    await svg.cache.putIfAbsent(
      loader.cacheKey(null),
      () => loader.loadBytes(null),
    );
  }
}
