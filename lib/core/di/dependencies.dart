import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:talker/talker.dart';

import '../../core/core.dart';
import '../../cubit/cubit.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';
import '../../features/features.dart';

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
  final mangaRepository = MangaRepository(mangaRemoteDataSource);
  getIt.registerSingleton<MangaRepository>(mangaRepository);
  getIt.registerSingleton<UtilsRepository>(
    UtilsRepository(utilsRemoteDataSource),
  );
  final userRepository = UserRepository(userRemoteDataSource);
  getIt.registerSingleton<UserRepository>(userRepository);
  // Register local repositories
  getIt.registerSingleton<SettingsRepository>(
    SettingsRepository(hiveDatasource),
  );
  final historyRepository = SearchHistoryRepository(hiveDatasource);
  getIt.registerSingleton<SearchHistoryRepository>(historyRepository);
  getIt.registerSingleton<SecureStorageDatasource>(
    secureStorage,
  );
  // Register blocs
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(userRepository, secureStorage),
  );
  getIt.registerFactory<FavoriteBloc>(
    () => FavoriteBloc(mangaRepository),
  );
  getIt.registerFactory<AppSettingsCubit>(() => AppSettingsCubit());
  getIt.registerFactory<SearchingBloc>(
    () => SearchingBloc(historyRepository, mangaRepository),
  );
}
