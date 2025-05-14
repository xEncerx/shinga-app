import 'package:flutter/material.dart';

class WaveGenerator extends StatelessWidget {
  const WaveGenerator({
    super.key,
    required this.color,
    required this.amplitude,
    required this.controlPoints,
    this.height,
    this.width,
    this.inverted = false,
  });

  final Color color;
  final double amplitude;
  final List<double> controlPoints;
  final double? height;
  final double? width;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width ?? double.infinity, height ?? double.infinity),
      painter: WavePainter(
        color: color,
        amplitude: amplitude,
        controlPoints: controlPoints,
        inverted: inverted,
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  WavePainter({
    required this.color,
    required this.amplitude,
    required this.controlPoints,
    this.inverted = false,
  });

  final Color color;
  final double amplitude;
  final List<double> controlPoints;
  final bool inverted;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(0, inverted ? 0 : size.height);

    final waveHeight = size.height * 0.6;
    final baseHeight = inverted ? waveHeight * amplitude : size.height - (waveHeight * amplitude);

    final double width = size.width;
    final int segments = controlPoints.length - 1;
    final double segmentWidth = width / segments;

    path.lineTo(0, baseHeight - (waveHeight * controlPoints[0] * (inverted ? -1 : 1)));

    for (int i = 0; i < segments; i++) {
      final double x1 = segmentWidth * i;
      final double x2 = segmentWidth * (i + 1);
      final double y1 =
          baseHeight - (waveHeight * controlPoints[i % controlPoints.length] * (inverted ? -1 : 1));
      final double y2 = baseHeight -
          (waveHeight * controlPoints[(i + 1) % controlPoints.length] * (inverted ? -1 : 1));

      final double cx1 = x1 + segmentWidth / 3;
      final double cy1 = y1;
      final double cx2 = x2 - segmentWidth / 3;
      final double cy2 = y2;

      path.cubicTo(cx1, cy1, cx2, cy2, x2, y2);
    }

    path.lineTo(size.width, inverted ? 0 : size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.controlPoints != controlPoints ||
        oldDelegate.inverted != inverted;
  }
}
