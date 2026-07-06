import 'dart:async';

import 'package:flutter/material.dart';

class StreamListener<T> extends StatefulWidget {
  const StreamListener({
    required this.stream,
    required this.child,
    this.onData,
    super.key,
  });

  final Stream<T> stream;
  final void Function(BuildContext context, T data)? onData;
  final Widget child;

  @override
  State<StreamListener<T>> createState() => _StreamListenerState<T>();
}

class _StreamListenerState<T> extends State<StreamListener<T>> {
  late StreamSubscription<T> _subscription;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant StreamListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream != widget.stream) {
      unawaited(_subscription.cancel());
      _subscribe();
    }
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }

  void _subscribe() {
    _subscription = widget.stream.listen((data) {
      if (mounted && widget.onData != null) {
        widget.onData!(context, data);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
