import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_requests/core/error/failures.dart';
import 'package:tracking_requests/features/requests/domain/repositories/request_repository.dart';
import 'package:tracking_requests/features/requests/domain/usecases/get_request_detail_usecase.dart';

import '../../../../_fixtures.dart';

class MockRequestRepository extends Mock implements RequestRepository {}

void main() {
  late GetRequestDetailUseCase usecase;
  late MockRequestRepository repository;

  setUp(() {
    repository = MockRequestRepository();
    usecase = GetRequestDetailUseCase(repository);
  });

  test('returns the request for the given localId', () async {
    // Arrange
    final tRequest = buildRequest();

    // Act
    when(
      () => repository.getRequestById(any()),
    ).thenAnswer((_) async => Right(tRequest));

    final result = await usecase(const GetRequestDetailParams('local-1'));

    // Assert
    expect(result, Right(tRequest));
    verify(() => repository.getRequestById('local-1')).called(1);
  });

  test('forwards a CacheFailure when the request is missing', () async {
    // Act
    when(
      () => repository.getRequestById(any()),
    ).thenAnswer((_) async => const Left(CacheFailure('not found')));

    final result = await usecase(const GetRequestDetailParams('missing'));

    // Assert
    expect(result, const Left(CacheFailure('not found')));
  });
}
