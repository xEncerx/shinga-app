import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shinga/core/initialization/model/dependencies.dart';

/// Owns application dependencies and releases them when the root detaches.
final class DependenciesLifecycle extends StatefulWidget {
  /// Creates a lifecycle owner for [dependencies].
  const DependenciesLifecycle({
    required this.dependencies,
    required this.child,
    super.key,
  });

  /// The long-lived dependencies to release.
  final Dependencies dependencies;

  /// The application widget tree.
  final Widget child;

  @override
  State<DependenciesLifecycle> createState() => _DependenciesLifecycleState();
}

final class _DependenciesLifecycleState extends State<DependenciesLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      unawaited(widget.dependencies.dispose());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(widget.dependencies.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
