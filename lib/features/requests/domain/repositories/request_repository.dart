import 'package:dartz/dartz.dart';
import 'package:tracking_requests/core/enums/request_category_enum.dart';
import 'package:tracking_requests/core/enums/request_priority_enum.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/features/requests/domain/entities/description_suggestion_entity.dart';
import 'package:tracking_requests/features/requests/domain/entities/request_entity.dart';
import '../../../../core/error/failures.dart';

abstract class RequestRepository {
  Stream<List<RequestEntity>> watchRequests({
    RequestStatusEnum? status,
    int limit,
  });

  Future<Either<Failure, Unit>> refreshRequests({
    RequestStatusEnum? status,
    int page,
  });

  Future<Either<Failure, RequestEntity>> getRequestById(String localId);

  Future<Either<Failure, RequestEntity>> createRequest({
    required String title,
    required String description,
    required RequestCategoryEnum category,
    required RequestPriorityEnum priority,
  });

  Future<Either<Failure, RequestEntity>> updateStatus({
    required String localId,
    required RequestStatusEnum status,
  });

  Future<Either<Failure, DescriptionSuggestionEntity>> suggestDescription(
    String title,
  );
}
