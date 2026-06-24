import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tracking_requests/core/constants/app_constants.dart';
import 'package:tracking_requests/core/enums/request_category_enum.dart';
import 'package:tracking_requests/core/enums/request_priority_enum.dart';
import 'package:tracking_requests/core/error/failures.dart';
import 'package:tracking_requests/core/usecases/usecase.dart';
import 'package:tracking_requests/features/requests/domain/entities/request_entity.dart';
import 'package:tracking_requests/features/requests/domain/repositories/request_repository.dart';

class CreateRequestUseCase
    implements UseCase<RequestEntity, CreateRequestParams> {
  final RequestRepository repository;
  const CreateRequestUseCase(this.repository);

  @override
  Future<Either<Failure, RequestEntity>> call(CreateRequestParams params) {
    final title = params.title.trim();
    final description = params.description.trim();

    if (title.isEmpty) {
      return Future.value(
        const Left(ValidationFailure('O título é obrigatório.')),
      );
    }
    if (description.length < AppConstants.minDescriptionLength) {
      return Future.value(
        Left(
          ValidationFailure(
            'A descrição deve ter ao menos '
            '${AppConstants.minDescriptionLength} caracteres.',
          ),
        ),
      );
    }

    return repository.createRequest(
      title: title,
      description: description,
      category: params.category,
      priority: params.priority,
    );
  }
}

class CreateRequestParams extends Equatable {
  final String title;
  final String description;
  final RequestCategoryEnum category;
  final RequestPriorityEnum priority;

  const CreateRequestParams({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
  });

  @override
  List<Object?> get props => [title, description, category, priority];
}
