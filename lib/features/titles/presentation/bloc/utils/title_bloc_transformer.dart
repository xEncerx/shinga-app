import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

/// An [EventTransformer] that throttles events and drops any new events while the previous one is still being processed.
EventTransformer<E> titleFetchPageTransformer<E>({
  Duration duration = const Duration(milliseconds: 300),
}) {
  return (events, mapper) {
    return droppable<E>().call(
      events.throttle(
        duration,
        trailing: true,
      ),
      mapper,
    );
  };
}

/// An [EventTransformer] that restarts the event stream on each new event, effectively canceling any ongoing processing.
EventTransformer<E> titleSearchTransformer<E>({
  Duration duration = const Duration(milliseconds: 400),
}) {
  return (events, mapper) {
    return restartable<E>().call(
      events.debounce(
        duration,
      ),
      mapper,
    );
  };
}
