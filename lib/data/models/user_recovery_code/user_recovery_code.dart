import 'package:freezed_annotation/freezed_annotation.dart';
part 'user_recovery_code.freezed.dart';
part 'user_recovery_code.g.dart';

@freezed
abstract class UserRecoveryCode with _$UserRecoveryCode {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserRecoveryCode({
    required String username,
    required String message,
    required String recoveryCode,
  }) = _UserRecoveryCode;

  factory UserRecoveryCode.fromJson(Map<String, dynamic> json) => _$UserRecoveryCodeFromJson(json);
}
