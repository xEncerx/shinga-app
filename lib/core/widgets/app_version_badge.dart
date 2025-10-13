import 'dart:math';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// A widget that displays the current app version in a styled badge.
class AppVersionBadge extends StatefulWidget {
  const AppVersionBadge({super.key});

  @override
  State<AppVersionBadge> createState() => _AppVersionBadgeState();
}

class _AppVersionBadgeState extends State<AppVersionBadge> {
  late final Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  /// Generates a gradient based on the version string.
  List<Color> _generateGradientFromVersion(String version, Color primaryColor) {
    final versionParts = version.split('.').map((part) {
      final numStr = part.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(numStr) ?? 0;
    }).toList();

    final seed = versionParts.fold(0, (sum, part) => sum + part);
    final hslColor = HSLColor.fromColor(primaryColor);
    final random = Random(seed);

    final lightnessDelta1 = random.nextDouble() * 0.15;
    final hueDelta1 = random.nextDouble() * 15 - 7.5;
    final color1 = hslColor
        .withLightness((hslColor.lightness + lightnessDelta1).clamp(0.2, 0.8))
        .withHue((hslColor.hue + hueDelta1) % 360)
        .toColor();

    final lightnessDelta2 = -(random.nextDouble() * 0.25 + 0.15);
    final saturationDelta = random.nextDouble() * 0.3 - 0.15;
    final hueDelta2 = random.nextDouble() * 20 - 10;
    final color2 = hslColor
        .withLightness((hslColor.lightness + lightnessDelta2).clamp(0.2, 0.8))
        .withSaturation((hslColor.saturation + saturationDelta).clamp(0.3, 1.0))
        .withHue((hslColor.hue + hueDelta2) % 360)
        .toColor();

    final lightnessDelta3 = random.nextDouble() * 0.2 - 0.1;
    final color3 = hslColor
        .withLightness((hslColor.lightness + lightnessDelta3).clamp(0.2, 0.8))
        .withSaturation((hslColor.saturation * 0.9).clamp(0.3, 1.0))
        .toColor();

    return [color1, color3, color2];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<PackageInfo>(
      future: _packageInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: 42,
            height: 20,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final version = snapshot.data?.version ?? '6.6.6';
        final gradientColors = _generateGradientFromVersion(
          version,
          theme.colorScheme.primary,
        );

        return Container(
          constraints: const BoxConstraints(
            minWidth: 42,
            maxWidth: 54,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.4),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'v$version',
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
