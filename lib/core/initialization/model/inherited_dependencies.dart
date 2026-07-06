import 'package:flutter/widgets.dart';
import 'package:shinga/core/initialization/model/dependencies.dart';

/// Inherited widget that provides access to the application's dependencies.
class InheritedDependencies extends InheritedWidget {
  /// Creates an [InheritedDependencies] widget.
  const InheritedDependencies({
    required this.dependencies,
    required super.child,
    super.key,
  });

  /// The dependencies provided by this widget.
  final Dependencies dependencies;

  /// Retrieves the dependencies from the closest [InheritedDependencies] widget in the widget tree.
  static Dependencies? maybeOf(BuildContext context) =>
      (context.getElementForInheritedWidgetOfExactType<InheritedDependencies>()?.widget
              as InheritedDependencies?)
          ?.dependencies;

  /// Retrieves the dependencies from the closest [InheritedDependencies] widget in the widget tree.
  static Dependencies of(BuildContext context) =>
      maybeOf(context) ??
      (throw ArgumentError(
        'Out of scope: InheritedDependencies not found',
        'out_of_scope',
      ));

  @override
  bool updateShouldNotify(InheritedDependencies oldWidget) => false;
}

/// Extension on [BuildContext] to easily access the dependencies provided by [InheritedDependencies].
extension GetDependencies on BuildContext {
  /// Retrieves the dependencies from the closest [InheritedDependencies] widget in the widget tree.
  Dependencies get deps => InheritedDependencies.of(this);
}
