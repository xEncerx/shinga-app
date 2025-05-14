import 'package:flutter/material.dart';

import 'wave_widget.dart';

class AuthScreenDecoration extends StatelessWidget {
  const AuthScreenDecoration({
    super.key,
    this.height = 200,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    final waveColor = Theme.of(context).colorScheme.primary;

    return Stack(
      children: [
        // Top waves
        Align(
          alignment: Alignment.topCenter,
          child: _buildWave(inverted: true, waveColor: waveColor),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: _buildWave(
            inverted: true,
            waveColor: waveColor,
            reversed: true,
          ),
        ),
        // Bottom waves
        Align(
          alignment: Alignment.bottomCenter,
          child: _buildWave(inverted: false, waveColor: waveColor),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _buildWave(
            inverted: false,
            waveColor: waveColor,
            reversed: true,
          ),
        ),
      ],
    );
  }

  Widget _buildWave({
    required bool inverted,
    required Color waveColor,
    bool reversed = false,
  }) {
    final controlPoints = reversed ? const [0.5, 0.2, 0.5, 0.2] : const [0.2, 0.5, 0.2, 0.5];

    return WaveGenerator(
      color: waveColor.withValues(alpha: 0.6),
      amplitude: 0.5,
      controlPoints: controlPoints,
      height: height,
      width: double.infinity,
      inverted: inverted,
    );
  }
}
