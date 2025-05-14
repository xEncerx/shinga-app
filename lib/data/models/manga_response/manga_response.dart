import 'package:json_annotation/json_annotation.dart';

part 'manga_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class MangaResponse<T> {
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
