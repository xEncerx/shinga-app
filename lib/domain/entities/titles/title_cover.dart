import 'package:freezed_annotation/freezed_annotation.dart';

part 'title_cover.freezed.dart';

/// Cover image URLs for a title.
@freezed
abstract class TitleCoverEntity with _$TitleCoverEntity {
  /// Creates a [TitleCoverEntity] instance.
  const factory TitleCoverEntity({
    /// The URL of the full-resolution cover image.
    required String original,

    /// The URL of the thumbnail cover image.
    required String thumbnail,
  }) = _TitleCoverEntity;
}
