import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:talker/talker.dart';

import '../../core/core.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final talker = Talker();
  final secureStorage = SecureStorageDatasource();
  final hiveDatasource = HiveDatasource();

  await hiveDatasource.initialize();

  final Dio dio = DioClient(talker: talker, secureStorage: secureStorage).createDio();

  final mangaRemoteDataSource = MangaRemoteDataSource(dio);
  final utilsRemoteDataSource = UtilsRemoteDataSource(dio);
  final userRemoteDataSource = UserRemoteDataSource(dio);

  // App routing
  getIt.registerSingleton<AppRouter>(AppRouter());

  // Register dependencies
  getIt.registerSingleton<Talker>(talker);
  getIt.registerSingleton<Dio>(dio);
  // Register API repositories
  getIt.registerSingleton<MangaRepository>(
    MangaRepository(mangaRemoteDataSource),
  );
  getIt.registerSingleton<UtilsRepository>(
    UtilsRepository(utilsRemoteDataSource),
  );
  getIt.registerSingleton<UserRepository>(
    UserRepository(userRemoteDataSource),
  );
  // Register local repositories
  getIt.registerSingleton<SettingsRepository>(
    SettingsRepository(hiveDatasource),
  );
  getIt.registerSingleton<SearchHistoryRepository>(
    SearchHistoryRepository(hiveDatasource),
  );
  getIt.registerSingleton<SecureStorageDatasource>(
    secureStorage,
  );
}
