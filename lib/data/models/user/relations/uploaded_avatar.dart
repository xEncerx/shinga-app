import 'package:freezed_annotation/freezed_annotation.dart';

part 'uploaded_avatar.freezed.dart';
part 'uploaded_avatar.g.dart';

@freezed
abstract class UploadedAvatar with _$UploadedAvatar {
  /// Represents an uploaded avatar response.
  /// 
  /// - `message` - A message indicating the result of the upload.
  /// - `avatar` - The Path of the uploaded avatar image.
  const factory UploadedAvatar({
    required String message,
    required String avatar,
  }) = _UploadedAvatar;

  factory UploadedAvatar.fromJson(Map<String, dynamic> json) => _$UploadedAvatarFromJson(json);
}
