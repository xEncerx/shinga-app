import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:retrofit/retrofit.dart';

import '../../../models/models.dart';
import 'call_adapter.dart';

part 'utils_api.g.dart';

/// API for user-related operations.
@RestApi(callAdapter: EitherCallAdapter)
abstract class UtilsApi {
  factory UtilsApi(Dio dio) = _UtilsApi;

  /// Uploads a file to the server.
  @POST('/upload/file/avatar')
  @MultiPart()
  Future<Either<HttpError, UploadedAvatar>> uploadAvatar({
    @Part(name: 'avatar') required File file,
  });
}
