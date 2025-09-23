import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_exception.freezed.dart';
part 'api_exception.g.dart';

@freezed
abstract class ApiException with _$ApiException {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ApiException({
    @Default(500) int statusCode,
    String? error,
    String? detail,
  }) = _ApiException;

  factory ApiException.fromJson(Map<String, dynamic> json) => _$ApiExceptionFromJson(json);
}
