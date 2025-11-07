import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:kl_teams/data/datasources/preference_local_datasource.dart';
import 'package:kl_teams/data/datasources/team_datasource.dart';
import 'package:kl_teams/data/models/preference_model.dart';
import 'package:kl_teams/data/repositories/preference_repository_impl.dart';
import 'package:kl_teams/data/repositories/team_repository_impl.dart';
import 'package:kl_teams/domain/repositories/preference_repository.dart';
import 'package:kl_teams/domain/repositories/team_repository.dart';
import 'package:kl_teams/presentation/cubits/api_cubit/api_cubit.dart';
import 'package:kl_teams/presentation/cubits/preference_cubit/preference_cubit.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Inicializar Hive
  await Hive.initFlutter();

  // Registrar adaptador de Hive
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(PreferenceModelAdapter());
  }

  // External
  sl.registerLazySingleton(() => http.Client());

  // Data Sources
  sl.registerLazySingleton<TeamDataSource>(
    () => TeamDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<PreferenceLocalDataSource>(
    () => PreferenceLocalDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<TeamRepository>(
    () => TeamRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<PreferenceRepository>(
    () => PreferenceRepositoryImpl(localDataSource: sl()),
  );

  // Cubits
  sl.registerFactory(() => ApiCubit(teamRepository: sl()));
  sl.registerFactory(() => PreferenceCubit(preferenceRepository: sl()));
}
