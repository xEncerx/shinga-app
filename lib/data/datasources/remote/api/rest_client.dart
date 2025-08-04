import 'package:dio/dio.dart';

import 'api.dart';

/// A client for making REST API calls.
class RestClient {
  /// Creates a new instance of [RestClient] with the provided [Dio] instance.
  RestClient({required this.dio});

  final Dio dio;

  TitlesApi? _titlesApi;
  UsersApi? _usersApi;
  AuthApi? _authApi;
  UtilsApi? _utilsApi;

  TitlesApi get titles => _titlesApi ??= TitlesApi(dio);
  UsersApi get users => _usersApi ??= UsersApi(dio);
  AuthApi get auth => _authApi ??= AuthApi(dio);
  UtilsApi get utils => _utilsApi ??= UtilsApi(dio);
}
