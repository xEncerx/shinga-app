import 'dart:async';

import 'package:shinga/domain/domain.dart';

/// Singleton stream bus for broadcasting title data changes.
class TitleUpdateBus {
  TitleUpdateBus._();

  /// The singleton instance of [TitleUpdateBus].
  static final TitleUpdateBus instance = TitleUpdateBus._();

  final StreamController<TitleWithUserDataEntity> _controller = StreamController.broadcast();

  /// Stream of updated title entities.
  Stream<TitleWithUserDataEntity> get updates => _controller.stream;

  /// Emits an updated [entity] to all listeners.
  void emit(TitleWithUserDataEntity entity) => _controller.add(entity);
}
