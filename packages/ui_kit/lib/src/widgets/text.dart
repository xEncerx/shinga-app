import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A text widget that displays a string with a single style.
///
/// This widget wraps Flutter's [Text] widget and provides consistent styling
/// across the application. It inherits text styles from [DefaultTextStyle]
/// and supports all standard text properties.
class SaText extends StatelessWidget {
  /// Creates a [SaText] widget.
  const SaText(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.selectionColor,
  }) : icon = null,
       iconSize = null,
       iconColor = null,
       iconAlignment = null,
       spacing = null;

  /// Creates a [SaText] widget with an icon.
  ///
  /// The [icon] is displayed next to the text with configurable alignment
  /// and spacing. The icon uses [SaIcon] for rendering.
  const SaText.icon(
    this.data, {
    required SaIconSource this.icon,
    super.key,
    this.iconSize,
    this.iconColor,
    this.iconAlignment = IconAlignment.start,
    this.spacing,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.selectionColor,
  });

  /// The text to display.
  final String data;

  /// The style to use for the text.
  ///
  /// If null, defaults to the [DefaultTextStyle] from the context.
  final TextStyle? style;

  /// The strut style to apply to the text.
  final StrutStyle? strutStyle;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// The directionality of the text.
  final TextDirection? textDirection;

  /// Used to select a font when the same Unicode character can be rendered differently.
  final Locale? locale;

  /// Whether the text should break at soft line breaks.
  final bool? softWrap;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  /// The text scaler to apply to the text.
  final TextScaler? textScaler;

  /// An optional maximum number of lines for the text to span.
  final int? maxLines;

  /// An alternative semantics label for this text.
  final String? semanticsLabel;

  /// The strategy to use when calculating the width of the text.
  final TextWidthBasis? textWidthBasis;

  /// The color to use when painting the selection.
  final Color? selectionColor;

  /// The icon source to display next to the text.
  ///
  /// Only used when created with [SaText.icon] constructor.
  final SaIconSource? icon;

  /// The size of the icon.
  ///
  /// If null, defaults to the icon theme size.
  final double? iconSize;

  /// The color of the icon.
  ///
  /// If null, defaults to the icon theme color or text color.
  final Color? iconColor;

  /// The alignment of the icon relative to the text.
  ///
  /// Defaults to [IconAlignment.start].
  final IconAlignment? iconAlignment;

  /// The spacing between the icon and text.
  ///
  /// If null, defaults to [AppSpacing.s].
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      data,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      selectionColor: selectionColor,
    );

    if (icon == null) {
      return textWidget;
    }

    return SaIconText(
      label: textWidget,
      spacing: spacing ?? AppSpacing.s,
      icon: SaIcon(
        icon: icon!,
        size: iconSize,
        color: iconColor ?? style?.color,
      ),
    );
  }
}
