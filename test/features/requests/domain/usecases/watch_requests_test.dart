import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/features/requests/domain/entities/request_entity.dart';
import 'package:tracking_requests/features/requests/domain/repositories/request_repository.dart';
import 'package:tracking_requests/features/requests/domain/usecases/watch_requests_usecase.dart';

import '../../../../_fixtures.dart';

class MockRequestRepository extends Mock implements RequestRepository {}

void main() {
  late WatchRequestsUseCase usecase;
  late MockRequestRepository repository;

  setUpAll(() => registerFallbackValue(RequestStatusEnum.open));

  setUp(() {
    repository = MockRequestRepository();
    usecase = WatchRequestsUseCase(repository);
  });

  test('forwards the reactive stream from the repository', () {
    // Arrange
    final tRequests = [buildRequest(), buildRequest(localId: 'local-2')];

    // Act
    when(
      () => repository.watchRequests(
        status: any(named: 'status'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) => Stream<List<RequestEntity>>.value(tRequests));

    final stream = usecase(const WatchRequestsParams());

    // Assert
    expect(stream, emits(tRequests));
  });

  test('passes the status filter and limit through', () {
    // Act
    when(
      () => repository.watchRequests(
        status: any(named: 'status'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) => Stream<List<RequestEntity>>.empty());

    usecase(
      const WatchRequestsParams(status: RequestStatusEnum.open, limit: 40),
    );

    // Assert
    verify(
      () => repository.watchRequests(status: RequestStatusEnum.open, limit: 40),
    ).called(1);
  });
}
