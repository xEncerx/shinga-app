import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../data.dart';

part 'available_genres.freezed.dart';
part 'available_genres.g.dart';

@freezed
abstract class AvailableGenres with _$AvailableGenres{
  /// Represents a collection of available genres.
  /// - `genres` - List of genres available in the application.
  const factory AvailableGenres({
    required List<GenreData> genres,
  }) = _AvailableGenres;

  factory AvailableGenres.fromJson(Map<String, dynamic> json) =>
      _$AvailableGenresFromJson(json);
}
