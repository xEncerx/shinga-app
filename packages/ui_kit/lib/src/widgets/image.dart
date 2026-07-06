import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';

/// Represents the source of an image (asset or network).
sealed class SaImageSource {
  /// Creates a [SaImageSource] instance.
  const SaImageSource();

  /// Creates an asset image source from [assetName].
  const factory SaImageSource.asset(String assetName) = _SaAssetImage;

  /// Creates a network image source from [url] with optional [useCache] (default = true).
  const factory SaImageSource.network(String url, {bool useCache}) = _SaNetworkImage;
}

/// Asset image source implementation.
final class _SaAssetImage extends SaImageSource {
  /// Creates a [_SaAssetImage] instance.
  const _SaAssetImage(this.assetName);

  /// The asset path.
  final String assetName;
}

/// Network image source implementation.
final class _SaNetworkImage extends SaImageSource {
  /// Creates a [_SaNetworkImage] instance.
  const _SaNetworkImage(this.url, {this.useCache = true});

  /// The network URL.
  final String url;

  /// Whether to cache the image.
  final bool useCache;
}

/// A versatile image widget that supports both asset and network images.
///
/// Provides built-in caching, loading placeholders, and error handling.
class SaImage extends StatefulWidget {
  /// Creates a [SaImage] widget.
  const SaImage({
    required this.image,
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.aspectRatio,
    this.scale = 1.0,
    this.opacity,
    this.fit = BoxFit.cover,
    this.filterQuality = FilterQuality.medium,
    this.placeholder,
    this.errorWidget,
  });

  /// The source of the image to display.
  final SaImageSource image;

  /// The width of the image.
  final double? width;

  /// The height of the image.
  final double? height;

  /// The border radius for rounding the corners of the image.
  final BorderRadius? borderRadius;

  /// The aspect ratio to maintain.
  final double? aspectRatio;

  /// The scale factor for the image.
  final double scale;

  /// How the image should be inscribed into the space.
  final BoxFit fit;

  /// The opacity of the image, between 0.0 (fully transparent) and 1.0 (fully opaque).
  final double? opacity;

  /// The quality of the image filtering.
  final FilterQuality filterQuality;

  /// Custom placeholder widget builder.
  final Widget Function(BuildContext ctx)? placeholder;

  /// Custom error widget builder.
  final Widget Function(BuildContext ctx, Object error, StackTrace? stackTrace)? errorWidget;

  @override
  State<SaImage> createState() => _SaImageState();
}

class _SaImageState extends State<SaImage> {
  late DisposableBuildContext<State<SaImage>> _scrollAwareContext;

  @override
  void initState() {
    super.initState();
    _scrollAwareContext = DisposableBuildContext<State<SaImage>>(this);
  }

  @override
  void dispose() {
    _scrollAwareContext.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    switch (widget.image) {
      // Build asset image
      case _SaAssetImage(:final assetName):
        imageWidget = Image.asset(
          assetName,
          fit: widget.fit,
          scale: widget.scale,
          filterQuality: widget.filterQuality,
          opacity: widget.opacity != null ? AlwaysStoppedAnimation(widget.opacity!) : null,
        );
      // Build network image with or without cache
      case _SaNetworkImage(:final url, :final useCache):
        imageWidget = OctoImage(
          image: ScrollAwareImageProvider(
            context: _scrollAwareContext,
            imageProvider: useCache
                ? CachedNetworkImageProvider(
                    url,
                    scale: widget.scale,
                  )
                : NetworkImage(
                    url,
                    scale: widget.scale,
                  ),
          ),
          fit: widget.fit,
          filterQuality: widget.filterQuality,
          placeholderBuilder: widget.placeholder,
          errorBuilder: widget.errorWidget,
          color: widget.opacity != null
              ? const Color(0xFFFFFFFF).withValues(alpha: widget.opacity)
              : null,
          colorBlendMode: widget.opacity != null ? BlendMode.modulate : null,
        );
    }

    // Apply border radius if specified
    if (widget.borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }

    // Wrap with AspectRatio if aspectRatio is specified
    if (widget.aspectRatio != null) {
      imageWidget = AspectRatio(
        aspectRatio: widget.aspectRatio!,
        child: imageWidget,
      );
    }

    // Wrap with SizedBox if width or height is specified
    if (widget.width != null || widget.height != null) {
      imageWidget = ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.width ?? double.infinity,
          maxHeight: widget.height ?? double.infinity,
        ),
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
