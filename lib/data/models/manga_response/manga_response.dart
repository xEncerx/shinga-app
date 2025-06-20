import 'package:json_annotation/json_annotation.dart';

part 'manga_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class MangaResponse<T> {
  /// Represents a response containing manga data.
  /// - `message` - A message associated with the response.
  /// - `content` - A list of items with `T` type. 
  MangaResponse({
    required this.message,
    required this.content,
  });
  
  factory MangaResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return _$MangaResponseFromJson(json, fromJsonT);
  }

  final String message;
  final List<T?> content;

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return _$MangaResponseToJson(this, toJsonT);
  }
}
