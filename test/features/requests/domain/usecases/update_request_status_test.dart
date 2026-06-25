import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/features/requests/domain/repositories/request_repository.dart';
import 'package:tracking_requests/features/requests/domain/usecases/update_request_status_usecase.dart';

import '../../../../_fixtures.dart';

class MockRequestRepository extends Mock implements RequestRepository {}

void main() {
  late UpdateRequestStatusUseCase usecase;
  late MockRequestRepository repository;

  setUpAll(() => registerFallbackValue(RequestStatusEnum.open));

  setUp(() {
    repository = MockRequestRepository();
    usecase = UpdateRequestStatusUseCase(repository);
  });

  test('delegates the status change to the repository', () async {
    // Arrange
    final tRequest = buildRequest(status: RequestStatusEnum.resolved);

    // Act
    when(
      () => repository.updateStatus(
        localId: any(named: 'localId'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async => Right(tRequest));

    final result = await usecase(
      const UpdateRequestStatusParams(
        localId: 'local-1',
        status: RequestStatusEnum.resolved,
      ),
    );

    // Assert
    expect(result, Right(tRequest));
    verify(
      () => repository.updateStatus(
        localId: 'local-1',
        status: RequestStatusEnum.resolved,
      ),
    ).called(1);
  });
}
