import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/features/features.dart';
import 'package:ui_kit/ui_kit.dart';

/// A slider widget that allows users to view and change their rating for a title.
class TitleDetailRatingSlider extends StatelessWidget {
  /// Creates a [TitleDetailRatingSlider] widget.
  const TitleDetailRatingSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TitleDetailCubit, TitleDetailState, double?>(
      selector: (state) => state.data.userData?.rating,
      builder: (_, userRating) {
        return userRating != null
            ? Container(
                height: 48,
                padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.m),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _RatingSlider(
                  initialRating: userRating,
                  onRatingChanged: (value) => context.read<TitleDetailCubit>().changeRating(value),
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }
}

class _RatingSlider extends StatefulWidget {
  const _RatingSlider({
    required this.initialRating,
    required this.onRatingChanged,
  });

  final double initialRating;
  final ValueChanged<double> onRatingChanged;

  @override
  State<_RatingSlider> createState() => __RatingSliderState();
}

class __RatingSliderState extends State<_RatingSlider> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 20,
          child: SaText(
            _currentRating.toStringAsFixed(0),
            style: AppTextStyle.bodyBold,
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape: const _IconThumbShape(icon: Icons.star),
            overlayShape: SliderComponentShape.noOverlay,
            tickMarkShape: SliderTickMarkShape.noTickMark,
          ),
          child: Slider(
            max: 10,
            divisions: 11,
            value: _currentRating,
            onChanged: (value) {
              setState(() => _currentRating = value);
            },
            onChangeEnd: widget.onRatingChanged,
          ),
        ),
      ],
    );
  }
}

class _IconThumbShape extends SliderComponentShape {
  const _IconThumbShape({
    required this.icon,

    /// Used in paint method
    // ignore: unused_element_parameter
    this.thumbRadius = 14,

    /// Used to set getPreferredSize
    // ignore: unused_element_parameter
    this.pressedThumbRadius = 16,
  });

  final IconData icon;
  final double thumbRadius;
  final double pressedThumbRadius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.fromRadius(pressedThumbRadius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    final currentRadius = Tween<double>(
      begin: thumbRadius,
      end: pressedThumbRadius,
    ).evaluate(activationAnimation);

    final paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.deepOrange
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, currentRadius, paint);

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: currentRadius,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    iconPainter.paint(
      canvas,
      center - Offset(iconPainter.width / 2, iconPainter.height / 2),
    );
  }
}
