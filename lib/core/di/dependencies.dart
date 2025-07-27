import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:talker/talker.dart';

import '../../core/core.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Logger
  final talker = Talker();
  getIt.registerSingleton<Talker>(talker);

  // Storages
  final secureStorage = SecureStorageRepository();
  final localDBRepo = LocalDatabaseRepository();
  await localDBRepo.initialize();

  getIt.registerSingleton<AppSettings>(localDBRepo.settings);
  getIt.registerSingleton<SecureStorageRepository>(secureStorage);
  getIt.registerSingleton<SearchHistoryRepository>(
    SearchHistoryRepository(localDBRepo.searchHistoryBox),
  );

  // AppRouter
  getIt.registerSingleton<AppRouter>(AppRouter());

  // Api Client
  final Dio dio = DioClient(
    talker: talker,
    secureStorage: secureStorage,
  ).createDio();
  final restClient = RestClient(dio: dio);
  getIt.registerSingleton<RestClient>(restClient);

  // Services
  getIt.registerSingleton<CacheService>(CacheService());
}
