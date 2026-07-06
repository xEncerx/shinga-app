import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_dto.freezed.dart';
part 'token_dto.g.dart';

/// A DTO representing the authentication token response returned by the API.
@freezed
abstract class TokenDTO with _$TokenDTO {
  /// Creates a [TokenDTO] instance.
  const factory TokenDTO({
    required String accessToken,
    @Default('Bearer') String tokenType,
  }) = _TokenDTO;

  /// Deserializes a [TokenDTO] from [json].
  factory TokenDTO.fromJson(Map<String, Object?> json) => _$TokenDTOFromJson(json);
}
