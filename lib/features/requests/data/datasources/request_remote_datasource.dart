import 'package:dio/dio.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/request_model.dart';

class PaginatedRequests {
  final List<RequestModel> items;
  final int totalCount;
  const PaginatedRequests({required this.items, required this.totalCount});
}

abstract class RequestRemoteDataSource {
  Future<PaginatedRequests> fetchRequests({
    RequestStatusEnum? status,
    required int page,
    required int limit,
  });

  Future<RequestModel> createRequest(RequestModel request);

  Future<RequestModel> updateStatus({
    required String remoteId,
    required RequestStatusEnum status,
  });
}

class RequestRemoteDataSourceImpl implements RequestRemoteDataSource {
  final Dio dio;
  RequestRemoteDataSourceImpl(this.dio);

  @override
  Future<PaginatedRequests> fetchRequests({
    RequestStatusEnum? status,
    required int page,
    required int limit,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.requests,
        queryParameters: {
          '_page': page,
          '_limit': limit,
          '_sort': 'createdAt',
          '_order': 'desc',
          if (status != null) 'status': status.apiValue,
        },
      );
      final list = (response.data as List).cast<Map<String, dynamic>>();
      final items = list.map(RequestModel.fromJson).toList();
      final total =
          int.tryParse(response.headers.value('X-Total-Count') ?? '') ??
          items.length;
      return PaginatedRequests(items: items, totalCount: total);
    } on DioException catch (e) {
      _throwMapped(e);
    }
  }

  @override
  Future<RequestModel> createRequest(RequestModel request) async {
    try {
      final response = await dio.post(
        ApiConstants.requests,
        data: request.toCreateJson(),
      );
      return RequestModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwMapped(e);
    }
  }

  @override
  Future<RequestModel> updateStatus({
    required String remoteId,
    required RequestStatusEnum status,
  }) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.requests}/$remoteId',
        data: {
          'status': status.apiValue,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
      return RequestModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwMapped(e);
    }
  }

  Never _throwMapped(DioException e) {
    final isConnectionIssue =
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout;
    if (isConnectionIssue) {
      throw const NetworkException();
    }
    throw ServerException(
      message: 'Falha na comunicação com o servidor.',
      statusCode: e.response?.statusCode,
    );
  }
}
