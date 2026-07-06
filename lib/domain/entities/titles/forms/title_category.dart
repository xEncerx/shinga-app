import 'package:freezed_annotation/freezed_annotation.dart';

part 'title_category.freezed.dart';

/// A form model representing a category option available in the system.
@freezed
abstract class TitleCategory with _$TitleCategory {
  /// Creates a [TitleCategory] instance.
  const factory TitleCategory({
    /// The canonical identifier name of the category in the system.
    required String name,

    /// The category name in Russian.
    required String ru,

    /// The category name in English.
    required String en,
  }) = _TitleCategory;
}
