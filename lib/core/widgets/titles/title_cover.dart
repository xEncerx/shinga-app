import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:shimmer/shimmer.dart';

/// A widget that displays title cover images with loading and error states.
///
/// This widget handles network images with caching support, shimmer loading effects,
/// and fallback error displays.
class TitleCover extends StatelessWidget {
  /// Creates a manga preview cover widget.
  /// - `width` - The width of the cover image.
  /// - `coverUrl` - The URL of the cover image to display.
  /// - `height` - The height of the cover image.
  /// - `borderRadius` - The border radius of the cover image.
  const TitleCover({
    super.key,
    required this.width,
    required this.coverUrl,
    this.height = double.infinity,
    this.borderRadius,
    this.useCache = true,
  });

  final String coverUrl;
  final double height;
  final double width;
  final BorderRadiusGeometry? borderRadius;
  final bool useCache;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(10),
      child: SizedBox(
        width: width,
        height: height,
        child: useCache
            ? CachedNetworkImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => _buildShimmer(theme),
                errorWidget: (_, _, _) => _buildErrorWidget(),
              )
            : OctoImage(
                image: NetworkImage(coverUrl),
                fit: BoxFit.cover,
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
}
