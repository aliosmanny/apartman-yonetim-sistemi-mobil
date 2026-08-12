import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../storage/secure_storage.dart';
import '../storage/local_storage.dart';
import '../../features/auth/data/datasources/auth_mock_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/controllers/auth_cubit.dart';
import '../../features/finance/data/datasources/finance_mock_data_source.dart';
import '../../features/finance/data/repositories/finance_repository_impl.dart';
import '../../features/finance/domain/repositories/finance_repository.dart';
import '../../features/finance/presentation/controllers/finance_cubit.dart';
import '../../features/maintenance/data/datasources/maintenance_mock_data_source.dart';
import '../../features/maintenance/data/repositories/maintenance_repository_impl.dart';
import '../../features/maintenance/domain/repositories/maintenance_repository.dart';
import '../../features/maintenance/presentation/controllers/maintenance_cubit.dart';
import '../config/app_environment.dart';

final GetIt sl = GetIt.instance;

/// Dependency Injection container'ı başlatır.
Future<void> initDependencies() async {
  // ── Storage ──────────────────────────────────────
  sl.registerLazySingleton<SecureStorage>(() => SecureStorage());

  final localStorage = await LocalStorage.create();
  sl.registerLazySingleton<LocalStorage>(() => localStorage);

  // ── Network ──────────────────────────────────────
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(sl<SecureStorage>()),
  );

  // ── Auth Data Sources ─────────────────────────────
  sl.registerLazySingleton<AuthMockDataSource>(
    () => AuthMockDataSource(),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl<ApiClient>().dio),
  );

  // ── Auth Repository ───────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      mockDataSource: sl<AuthMockDataSource>(),
      secureStorage: sl<SecureStorage>(),
      useMock: AppEnvironment.useMock,
    ),
  );

  // ── Cubit'ler ─────────────────────────────────────
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(sl<AuthRepository>()),
  );

  // ── Finance Data Sources & Repositories ────────────
  sl.registerLazySingleton<FinanceMockDataSource>(
    () => FinanceMockDataSource(),
  );

  sl.registerLazySingleton<FinanceRepository>(
    () => FinanceRepositoryImpl(
      mockDataSource: sl<FinanceMockDataSource>(),
    ),
  );

  // ── Finance Cubit ─────────────────────────────────
  sl.registerFactory<FinanceCubit>(
    () => FinanceCubit(sl<FinanceRepository>()),
  );

  // ── Maintenance Data Sources & Repositories ────────
  sl.registerLazySingleton<MaintenanceMockDataSource>(
    () => MaintenanceMockDataSource(),
  );

  sl.registerLazySingleton<MaintenanceRepository>(
    () => MaintenanceRepositoryImpl(
      mockDataSource: sl<MaintenanceMockDataSource>(),
    ),
  );

  sl.registerFactory<MaintenanceCubit>(
    () => MaintenanceCubit(sl<MaintenanceRepository>()),
  );
}
