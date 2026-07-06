import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/domain/entities/entities.dart';

part 'session.freezed.dart';

/// A domain entity representing an authenticated user session.
@freezed
abstract class Session with _$Session {
  /// Creates a [Session] instance.
  const factory Session({
    /// The authenticated user associated with this session.
    required UserEntity user,
  }) = _Session;
}
