import 'package:freezed_annotation/freezed_annotation.dart';

part 'title_genre.freezed.dart';

/// A form model representing a genre option available in the system.
@freezed
abstract class TitleGenre with _$TitleGenre {
  /// Creates a [TitleGenre] instance.
  const factory TitleGenre({
    /// The canonical identifier name of the genre in the system.
    required String name,

    /// The genre name in Russian.
    required String ru,

    /// The genre name in English.
    required String en,
  }) = _TitleGenre;
}
