/// Localised human-readable representation of an AppFailure.
///
/// Produced by `AppFailure.toMessage()` and consumed in the UI layer.
class FailureMessage {
  /// Creates a [FailureMessage] with the given [title] and [description].
  const FailureMessage({
    required this.title,
    required this.description,
  });

  /// Short, user-facing title of the error.
  final String title;

  /// Longer explanation of what went wrong and/or how to resolve it.
  final String description;
}
