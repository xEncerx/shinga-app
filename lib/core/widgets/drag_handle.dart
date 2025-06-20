import 'package:flutter/material.dart';

/// A visual handle widget used to indicate draggable surfaces.
/// 
/// Used for BottomSheet and other draggable components to provide a
/// consistent and recognizable drag handle.
class DragHandle extends StatelessWidget {
  /// Creates a drag handle widget.
  const DragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 35,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).hintColor,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
