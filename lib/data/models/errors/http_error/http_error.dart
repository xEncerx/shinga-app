import 'package:freezed_annotation/freezed_annotation.dart';

part 'http_error.freezed.dart';
part 'http_error.g.dart';

@freezed
abstract class HttpError with _$HttpError{
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory HttpError({
    @Default(500) int statusCode,
    String? error,
    String? detail,
  }) = _HttpError;

  factory HttpError.fromJson(Map<String, dynamic> json) =>
      _$HttpErrorFromJson(json);
}
