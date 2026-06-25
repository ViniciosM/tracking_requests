import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/error/failures.dart';
import 'package:tracking_requests/features/requests/domain/repositories/request_repository.dart';
import 'package:tracking_requests/features/requests/domain/usecases/refresh_requests_usecase.dart';

class MockRequestRepository extends Mock implements RequestRepository {}

void main() {
  late RefreshRequestsUseCase usecase;
  late MockRequestRepository repository;

  setUpAll(() => registerFallbackValue(RequestStatusEnum.open));

  setUp(() {
    repository = MockRequestRepository();
    usecase = RefreshRequestsUseCase(repository);
  });

  test('delegates the page fetch to the repository', () async {
    // Act
    when(
      () => repository.refreshRequests(
        status: any(named: 'status'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) async => const Right(unit));

    final result = await usecase(const RefreshRequestsParams(page: 2));

    // Assert
    expect(result, const Right(unit));
    verify(() => repository.refreshRequests(status: null, page: 2)).called(1);
  });

  test('forwards a NetworkFailure', () async {
    // Act
    when(
      () => repository.refreshRequests(
        status: any(named: 'status'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) async => const Left(NetworkFailure()));

    final result = await usecase(const RefreshRequestsParams());

    // Assert
    expect(result, const Left(NetworkFailure()));
  });
}
