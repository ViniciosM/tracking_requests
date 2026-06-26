import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:tracking_requests/core/design_system/brand_config.dart';
import 'package:tracking_requests/features/auth/data/sync/request_sync_processor.dart';
import 'package:tracking_requests/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:tracking_requests/features/auth/domain/usecases/login_usecase.dart';
import 'package:tracking_requests/features/auth/domain/usecases/logout_usecase.dart';
import 'package:tracking_requests/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tracking_requests/features/requests/domain/usecases/create_request_usecase.dart';
import 'package:tracking_requests/features/requests/domain/usecases/get_request_detail_usecase.dart';
import 'package:tracking_requests/features/requests/domain/usecases/refresh_requests_usecase.dart';
import 'package:tracking_requests/features/requests/domain/usecases/suggest_category_usecase.dart';
import 'package:tracking_requests/features/requests/domain/usecases/update_request_status_usecase.dart';
import 'package:tracking_requests/features/requests/domain/usecases/watch_requests_usecase.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/create/create_request_bloc.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/detail/request_detail_bloc.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/list/request_list_bloc.dart';
import 'package:uuid/uuid.dart';
import '../db/daos/request_dao.dart';
import '../db/daos/sync_queue_dao.dart';
import '../db/database.dart';
import '../network/dio_client.dart';
import '../network/gemini_client.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';
import '../storage/secure_storage_service.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/requests/data/datasources/ai_remote_datasource.dart';
import '../../features/requests/data/datasources/request_local_datasource.dart';
import '../../features/requests/data/datasources/request_remote_datasource.dart';
import '../../features/requests/data/datasources/sync_queue_local_datasource.dart';
import '../../features/requests/data/repositories/request_repository_impl.dart';
import '../../features/requests/domain/repositories/request_repository.dart';

final GetIt getIt = GetIt.instance;

const String apiDio = 'apiDio';
const String geminiDio = 'geminiDio';

Future<void> setupDependencies({required BrandConfig brand}) async {
  final geminiKey = await _loadGeminiKey();
  registerDependencies(geminiKey: geminiKey, brand: brand);
  getIt<SyncService>().start();
}

Future<String> _loadGeminiKey() async {
  try {
    await dotenv.load(fileName: '.env');
    return dotenv.env['GEMINI_API_KEY'] ?? '';
  } catch (_) {
    return '';
  }
}

void registerDependencies({
  required String geminiKey,
  required BrandConfig brand,
}) {
  _registerCore(geminiKey, brand);
  _registerAuth();
  _registerRequests();
}

void _registerCore(String geminiKey, BrandConfig brand) {
  getIt
    ..registerSingleton<BrandConfig>(brand)
    ..registerLazySingleton<Uuid>(() => const Uuid())
    ..registerLazySingleton<ConnectivityService>(
      () => InternetConnectivityService(),
    )
    ..registerLazySingleton<SecureStorageService>(
      () => FlutterSecureStorageService(),
    )
    ..registerLazySingleton<AppDatabase>(() => AppDatabase())
    ..registerLazySingleton<RequestDao>(() => getIt<AppDatabase>().requestDao)
    ..registerLazySingleton<SyncQueueDao>(
      () => getIt<AppDatabase>().syncQueueDao,
    )
    ..registerLazySingleton<Dio>(
      () => DioClient.create(
        storage: getIt(),
        baseUrl: getIt<BrandConfig>().apiBaseUrl,
      ),
      instanceName: apiDio,
    )
    ..registerLazySingleton<Dio>(
      () => GeminiClient.create(apiKey: geminiKey),
      instanceName: geminiDio,
    );
}

void _registerAuth() {
  getIt
    // data sources
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt<Dio>(instanceName: apiDio)),
    )
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(getIt()),
    )
    // repository
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remote: getIt(), local: getIt()),
    )
    // use cases
    ..registerLazySingleton(() => LoginUseCase(getIt()))
    ..registerLazySingleton(() => LogoutUseCase(getIt()))
    ..registerLazySingleton(() => CheckAuthStatusUseCase(getIt()))
    ..registerFactory(
      () => AuthBloc(login: getIt(), logout: getIt(), checkAuthStatus: getIt()),
    );
}

void _registerRequests() {
  getIt
    // data sources
    ..registerLazySingleton<RequestRemoteDataSource>(
      () => RequestRemoteDataSourceImpl(getIt<Dio>(instanceName: apiDio)),
    )
    ..registerLazySingleton<RequestLocalDataSource>(
      () => RequestLocalDataSourceImpl(dao: getIt(), uuid: getIt()),
    )
    ..registerLazySingleton<SyncQueueLocalDataSource>(
      () => SyncQueueLocalDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<AiRemoteDataSource>(
      () => GeminiAiRemoteDataSource(dio: getIt<Dio>(instanceName: geminiDio)),
    )
    // repository
    ..registerLazySingleton<RequestRepository>(
      () => RequestRepositoryImpl(
        remote: getIt(),
        local: getIt(),
        syncQueue: getIt(),
        ai: getIt(),
        connectivity: getIt(),
        uuid: getIt(),
      ),
    )
    // use cases
    ..registerLazySingleton(() => WatchRequestsUseCase(getIt()))
    ..registerLazySingleton(() => RefreshRequestsUseCase(getIt()))
    ..registerLazySingleton(() => GetRequestDetailUseCase(getIt()))
    ..registerLazySingleton(() => CreateRequestUseCase(getIt()))
    ..registerLazySingleton(() => UpdateRequestStatusUseCase(getIt()))
    ..registerLazySingleton(() => SuggestCategoryUseCase(getIt()))
    // sync engine
    ..registerLazySingleton<SyncProcessor>(
      () => RequestSyncProcessor(requestDao: getIt(), remote: getIt()),
    )
    ..registerLazySingleton<SyncService>(
      () => SyncService(
        connectivity: getIt(),
        queueDao: getIt(),
        processor: getIt(),
      ),
    )
    // blocs
    ..registerFactory(
      () => RequestsListBloc(
        watchRequests: getIt(),
        refreshRequests: getIt(),
        syncService: getIt(),
        connectivity: getIt(),
      ),
    )
    ..registerFactory(
      () => RequestDetailBloc(
        getRequestDetail: getIt(),
        updateRequestStatus: getIt(),
      ),
    )
    ..registerFactory(
      () => CreateRequestBloc(createRequest: getIt(), suggestCategory: getIt()),
    );
}
