import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracking_requests/core/design_system/brand_config.dart';
import 'package:tracking_requests/core/di/injection.dart';
import 'package:tracking_requests/core/services/sync_service.dart';
import 'package:tracking_requests/features/auth/domain/repositories/auth_repository.dart';
import 'package:tracking_requests/features/auth/domain/usecases/login_usecase.dart';
import 'package:tracking_requests/features/requests/domain/repositories/request_repository.dart';
import 'package:tracking_requests/features/requests/domain/usecases/create_request_usecase.dart';

void main() {
  setUp(() => registerDependencies(geminiKey: 'test-key', brand: BrandA()));

  tearDown(() => getIt.reset());

  test('registers the public contracts and use cases', () {
    expect(getIt.isRegistered<AuthRepository>(), isTrue);
    expect(getIt.isRegistered<RequestRepository>(), isTrue);
    expect(getIt.isRegistered<LoginUseCase>(), isTrue);
    expect(getIt.isRegistered<CreateRequestUseCase>(), isTrue);
    expect(getIt.isRegistered<SyncService>(), isTrue);
  });

  test('resolves the full dependency graph without throwing', () {
    expect(() => getIt<AuthRepository>(), returnsNormally);
    expect(() => getIt<RequestRepository>(), returnsNormally);
    expect(() => getIt<SyncService>(), returnsNormally);
  });

  test('the two named Dio instances are registered', () {
    expect(getIt.isRegistered<Dio>(instanceName: apiDio), isTrue);
    expect(getIt.isRegistered<Dio>(instanceName: geminiDio), isTrue);
  });

  test('registers the brand, contracts and use cases', () {
    expect(getIt.isRegistered<BrandConfig>(), isTrue);
    expect(getIt.isRegistered<AuthRepository>(), isTrue);
    expect(getIt.isRegistered<RequestRepository>(), isTrue);
    expect(getIt.isRegistered<LoginUseCase>(), isTrue);
    expect(getIt.isRegistered<CreateRequestUseCase>(), isTrue);
    expect(getIt.isRegistered<SyncService>(), isTrue);
  });

  test('resolves the full dependency graph without throwing', () {
    expect(() => getIt<AuthRepository>(), returnsNormally);
    expect(() => getIt<RequestRepository>(), returnsNormally);
    expect(() => getIt<SyncService>(), returnsNormally);
  });
}
