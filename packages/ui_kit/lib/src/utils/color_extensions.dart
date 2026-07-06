import 'package:flutter/material.dart';
import 'package:ui_kit/src/src.dart';

/// Extension on [Color] providing adaptive foreground color computation.
extension ColorX on Color {
  /// Material Design luminance threshold: backgrounds above this value are
  /// considered "light" and require a dark foreground.
  static const double _luminanceThreshold = 0.337;

  /// Returns a foreground [Color] that is readable on this background color.
  ///
  /// Blends semi-transparent colors with [ColorScheme.surface] first, then
  /// applies the Material Design luminance threshold (0.337) to decide
  /// whether a dark or light foreground is needed.
  ///
  /// Rather than assuming which of [ColorScheme.onSurface] /
  /// [ColorScheme.onInverseSurface] is light or dark, their actual luminance
  /// values are compared at runtime.
  Color foreground(BuildContext context) {
    final scheme = context.colors;
    final solid = Color.alphaBlend(this, scheme.surface);

    final bgLuminance = solid.computeLuminance();
    final needsDarkForeground = bgLuminance > _luminanceThreshold;

    final onSurface = scheme.onSurface;
    final onInverse = scheme.onInverseSurface;
    final onSurfaceLum = onSurface.computeLuminance();
    final onInverseLum = onInverse.computeLuminance();

    return needsDarkForeground
        ? (onSurfaceLum <= onInverseLum ? onSurface : onInverse)
        : (onSurfaceLum >= onInverseLum ? onSurface : onInverse);
  }

  /// Returns a semi-transparent version of this color suitable for splash effects.
  Color splashColor() => withValues(alpha: 0.2);

  /// Returns a semi-transparent version of this color suitable for highlight effects.
  Color highlightColor() => withValues(alpha: 0.1);

  /// Returns a semi-transparent version of this color suitable for hover effects.
  Color hoverColor() => withValues(alpha: 0.2);
}
