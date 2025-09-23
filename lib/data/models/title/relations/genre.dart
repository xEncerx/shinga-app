import 'package:freezed_annotation/freezed_annotation.dart';

part 'genre.freezed.dart';
part 'genre.g.dart';

@freezed
abstract class GenreData with _$GenreData {
  /// Represents a genre in the application.
  /// `ru` - Russian name of the genre.
  /// `en` - English name of the genre.
  const factory GenreData({
    required String ru,
    required String en,
  }) = _GenreData;

  factory GenreData.fromJson(Map<String, dynamic> json) => _$GenreDataFromJson(json);
}
