import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';

/// A widget that displays manga cover images with loading and error states.
///
/// This widget handles network images with caching support, shimmer loading effects,
/// and fallback error displays.
class MangaPreviewCover extends StatelessWidget {
  /// Creates a manga preview cover widget.
  /// - `coverUrl` - The URL of the cover image to display.
  /// - `width` - The width of the cover image.
  /// - `height` - The height of the cover image.
  /// - `useCoverCache` - Whether to use cached images for better performance.
  /// - `borderRadius` - The border radius of the cover image.
  const MangaPreviewCover({
    super.key,
    required this.coverUrl,
    this.width = 110,
    this.height = double.infinity,
    this.useCoverCache = true,
    this.borderRadius,
  });

  final String coverUrl;
  final double height;
  final double width;
  final bool useCoverCache;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(10),
      child: SizedBox(
        width: width,
        height: height,
        child: useCoverCache
            ? CachedNetworkImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => _buildShimmer(theme),
                errorWidget: (_, _, _) => _buildErrorWidget(),
              )
            : OctoImage(
                image: NetworkImage(coverUrl),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
                placeholderBuilder: (_) => _buildShimmer(theme),
                errorBuilder: (_, _, _) => _buildErrorWidget(),
              ),
      ),
    );
  }

  /// Builds a shimmer loading effect for when the image is loading.
  Widget _buildShimmer(ThemeData theme) {
    return Shimmer.fromColors(
      baseColor: theme.hintColor,
      highlightColor: Color.lerp(theme.hintColor, Colors.white, 0.1)!,
      period: const Duration(seconds: 1),
      child: ColoredBox(color: theme.hintColor),
    );
  }

  /// Builds a fallback widget when an error occurs loading the image.
  Widget _buildErrorWidget() {
    return Image.asset(
      "assets/images/404_placeholder.png",
      fit: BoxFit.cover,
    );
  }

  /// Clears the image cache used by this widget.
  ///
  /// Useful for freeing up disk space or refreshing stale images.
  static Future<void> clearCache() async {
    final Directory tempDir = await getTemporaryDirectory();
    final Directory libCacheDir = Directory("${tempDir.path}/libCachedImageData");
    await libCacheDir.delete(recursive: true);
  }
}
