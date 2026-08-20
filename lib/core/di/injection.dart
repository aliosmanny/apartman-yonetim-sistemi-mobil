import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../storage/secure_storage.dart';
import '../storage/local_storage.dart';
import '../../features/auth/data/datasources/auth_mock_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/controllers/auth_cubit.dart';
import '../../features/finance/data/datasources/finance_remote_data_source.dart';
import '../../features/finance/data/repositories/finance_repository_impl.dart';
import '../../features/finance/domain/repositories/finance_repository.dart';
import '../../features/finance/presentation/controllers/finance_cubit.dart';
import '../../features/maintenance/data/datasources/maintenance_remote_data_source.dart';
import '../../features/maintenance/data/repositories/maintenance_repository_impl.dart';
import '../../features/maintenance/domain/repositories/maintenance_repository.dart';
import '../../features/maintenance/presentation/controllers/maintenance_cubit.dart';
import '../../features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import '../../features/dashboard/presentation/controllers/dashboard_cubit.dart';
import '../../features/notifications/data/datasources/notification_remote_data_source.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/presentation/controllers/notification_cubit.dart';
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
  sl.registerLazySingleton<FinanceRemoteDataSource>(
    () => FinanceRemoteDataSourceImpl(sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<FinanceRepository>(
    () => FinanceRepositoryImpl(
      sl<FinanceRemoteDataSource>(),
    ),
  );

  // ── Finance Cubit ─────────────────────────────────
  sl.registerFactory<FinanceCubit>(
    () => FinanceCubit(sl<FinanceRepository>()),
  );

  // ── Maintenance Data Sources & Repositories ────────
  sl.registerLazySingleton<MaintenanceRemoteDataSource>(
    () => MaintenanceRemoteDataSourceImpl(sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<MaintenanceRepository>(
    () => MaintenanceRepositoryImpl(
      sl<MaintenanceRemoteDataSource>(),
    ),
  );

  sl.registerFactory<MaintenanceCubit>(
    () => MaintenanceCubit(sl<MaintenanceRepository>()),
  );

  // ── Dashboard Data Source & Cubit ────────────────
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSource(sl<ApiClient>().dio),
  );

  sl.registerFactory<DashboardCubit>(
    () => DashboardCubit(sl<DashboardRemoteDataSource>()),
  );

  // ── Notifications Data Source & Cubit ────────────
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl<NotificationRemoteDataSource>()),
  );

  sl.registerFactory<NotificationCubit>(
    () => NotificationCubit(sl<NotificationRepository>()),
  );
}
