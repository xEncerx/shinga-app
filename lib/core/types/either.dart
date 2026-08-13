import 'package:meta/meta.dart';

/// Represents a value that is either a failure [L] or a success [R].
///
/// Exactly one branch is present and can be handled through [fold] or an
/// exhaustive pattern-matching switch.
@immutable
sealed class Either<L, R> {
  /// Creates an [Either] branch.
  const Either();

  /// Whether this result contains a failure value.
  bool get isLeft;

  /// Whether this result contains a success value.
  bool get isRight;

  /// Handles the active branch and returns the callback result.
  T fold<T>(T Function(L value) onLeft, T Function(R value) onRight);

  /// Returns the success value or lazily creates a fallback for a failure.
  R getOrElse(R Function(L value) onLeft);
}

/// The failure branch of [Either].
final class Left<L, R> extends Either<L, R> {
  /// Creates a failure result containing [value].
  const Left(this.value);

  /// The failure value.
  final L value;

  @override
  bool get isLeft => true;

  @override
  bool get isRight => false;

  @override
  T fold<T>(T Function(L value) onLeft, T Function(R value) onRight) => onLeft(value);

  @override
  R getOrElse(R Function(L value) onLeft) => onLeft(value);

  @override
  bool operator ==(Object other) => other is Left<L, R> && other.value == value;

  @override
  int get hashCode => Object.hash(Left, value);

  @override
  String toString() => 'Left($value)';
}

/// The success branch of [Either].
final class Right<L, R> extends Either<L, R> {
  /// Creates a success result containing [value].
  const Right(this.value);

  /// The success value.
  final R value;

  @override
  bool get isLeft => false;

  @override
  bool get isRight => true;

  @override
  T fold<T>(T Function(L value) onLeft, T Function(R value) onRight) => onRight(value);

  @override
  R getOrElse(R Function(L value) onLeft) => value;

  @override
  bool operator ==(Object other) => other is Right<L, R> && other.value == value;

  @override
  int get hashCode => Object.hash(Right, value);

  @override
  String toString() => 'Right($value)';
}

/// Provides callback handling without a synthetic success value.
extension EitherVoidFold<L> on Either<L, void> {
  /// Handles a failure value or a successful operation with no result.
  T foldVoid<T>(T Function(L value) onLeft, T Function() onRight) => fold(onLeft, (_) => onRight());
}
