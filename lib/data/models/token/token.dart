import 'package:freezed_annotation/freezed_annotation.dart';
part 'token.freezed.dart';
part 'token.g.dart';

@freezed
abstract class Token with _$Token {
  /// Represents an authentication token.
  /// - `accessToken` - The access token string.
  /// - `tokenType` - The type of token, defaulting to 'bearer'.
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Token({
    required String accessToken,
    @Default('bearer') String tokenType,
  }) = _Token;

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);
}
