import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// Displays a title's cover image.
///
/// Shows a shimmer placeholder while loading and a 404 placeholder image on error.
class TitleCover extends StatelessWidget {
  /// Creates a [TitleCover] widget.
  const TitleCover({
    required this.coverUrl,
    super.key,
    this.width,
    this.height,
    this.aspectRatio,
    this.borderRadius,
    this.opacity,
    this.useCache = true,
  });

  /// The URL of the cover image to display.
  final String coverUrl;

  /// The explicit width of the cover. If null, sized by [aspectRatio] or parent constraints.
  final double? width;

  /// The explicit height of the cover. If null, sized by [aspectRatio] or parent constraints.
  final double? height;

  /// The aspect ratio (width / height) used to size the cover when [width] or [height] is not set.
  final double? aspectRatio;

  /// The border radius applied to the cover image. Defaults to [AppRadius.card].
  final BorderRadius? borderRadius;

  /// Whether to use cached network images. Defaults to `true`.
  final bool useCache;

  /// The opacity of the cover image, between 0.0 (fully transparent) and 1.0 (fully opaque).
  final double? opacity;

  @override
  Widget build(BuildContext context) {
    return SaImage(
      image: SaImageSource.network(coverUrl, useCache: useCache),
      width: width,
      height: height,
      aspectRatio: aspectRatio ?? 2 / 3,
      borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.card),
      placeholder: (_) => const SaShimmer(),
      opacity: opacity,
      errorWidget: (_, _, _) => const SaImage(
        image: SaImageSource.asset('assets/images/404_placeholder.png'),
      ),
    );
  }
}
