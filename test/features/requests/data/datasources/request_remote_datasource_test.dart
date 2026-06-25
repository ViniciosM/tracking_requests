import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/error/exceptions.dart';
import 'package:tracking_requests/features/requests/data/datasources/request_remote_datasource.dart';

import '../../../../_fixtures.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late RequestRemoteDataSourceImpl dataSource;
  late MockDio dio;

  setUp(() {
    dio = MockDio();
    dataSource = RequestRemoteDataSourceImpl(dio);
  });

  final options = RequestOptions(path: '/requests');

  group('fetchRequests', () {
    test('parses the list and reads X-Total-Count', () async {
      // Act
      when(
        () => dio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: options,
          statusCode: 200,
          data: [
            requestJson(id: '1'),
            requestJson(id: '2'),
          ],
          headers: Headers.fromMap({
            'X-Total-Count': ['24'],
          }),
        ),
      );

      final result = await dataSource.fetchRequests(page: 1, limit: 20);

      // Assert
      expect(result.items.length, 2);
      expect(result.totalCount, 24);
      expect(result.items.first.remoteId, '1');
    });

    test('falls back to item count when the header is absent', () async {
      // Act
      when(
        () => dio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: options,
          statusCode: 200,
          data: [requestJson(id: '1')],
        ),
      );

      final result = await dataSource.fetchRequests(page: 1, limit: 20);

      // Assert
      expect(result.totalCount, 1);
    });

    test('maps a connection error to NetworkException', () async {
      // Act
      when(
        () => dio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        ),
      );

      // Assert
      await expectLater(
        dataSource.fetchRequests(page: 1, limit: 20),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  test('createRequest returns the persisted model with a remoteId', () async {
    // Act
    when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => Response(
        requestOptions: options,
        statusCode: 201,
        data: requestJson(id: '99'),
      ),
    );

    final result = await dataSource.createRequest(buildModel());

    // Assert
    expect(result.remoteId, '99');
  });

  test('updateStatus maps a 500 to ServerException', () async {
    // Act
    when(() => dio.patch(any(), data: any(named: 'data'))).thenThrow(
      DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: options, statusCode: 500),
      ),
    );

    // Assert
    await expectLater(
      dataSource.updateStatus(
        remoteId: 'r1',
        status: RequestStatusEnum.resolved,
      ),
      throwsA(isA<ServerException>()),
    );
  });
}
