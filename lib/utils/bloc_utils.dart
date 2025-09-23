import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

const kThrottleDuration = Duration(milliseconds: 250);

EventTransformer<E> throttleDroppable<E>({
  bool trailing = false,
  Duration duration = kThrottleDuration,
}) {
  return (events, mapper) {
    return droppable<E>().call(
      events.throttle(
        duration,
        trailing: trailing,
      ),
      mapper,
    );
  };
}
