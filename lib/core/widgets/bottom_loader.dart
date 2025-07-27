import 'package:flutter/material.dart';

/// A widget that displays a loading indicator at the bottom of a list.
class BottomLoader extends StatelessWidget {
  /// Creates a [BottomLoader] widget.
  const BottomLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          height: 32,
          width: 32,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
