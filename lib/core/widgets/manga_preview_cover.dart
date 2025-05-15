import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talker/talker.dart';

class MangaPreviewCover extends StatelessWidget {
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
                placeholder: (_, __) => _buildShimmer(theme),
                errorWidget: (_, __, error) => _buildErrorWidget(error),
              )
            : Image.network(
                coverUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildShimmer(theme);
                },
                errorBuilder: (context, error, stackTrace) => _buildErrorWidget(error),
              ),
      ),
    );
  }

  Widget _buildShimmer(ThemeData theme) {
    return Shimmer.fromColors(
      baseColor: theme.hintColor,
      highlightColor: Color.lerp(theme.hintColor, Colors.white, 0.1)!,
      period: const Duration(seconds: 1),
      child: ColoredBox(color: theme.hintColor),
    );
  }

  // * This is a temporary error widget. It should be replaced with a better one.
  Widget _buildErrorWidget(Object? errorMessage) {
    GetIt.I<Talker>().error(
      "Failed to load cover image: $errorMessage",
    );

    return const ColoredBox(
      color: Colors.red,
      child: Icon(
        Icons.error,
        color: Colors.white,
      ),
    );
  }

  static Future<void> clearCache() async {
    final Directory tempDir = await getTemporaryDirectory();
    final Directory libCacheDir = Directory("${tempDir.path}/libCachedImageData");
    await libCacheDir.delete(recursive: true);
  }
}
