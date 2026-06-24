import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tracking_requests/core/constants/app_constants.dart';
import 'package:tracking_requests/core/error/failures.dart';
import 'package:tracking_requests/core/usecases/usecase.dart';
import 'package:tracking_requests/features/requests/domain/entities/category_suggestion_entity.dart';
import 'package:tracking_requests/features/requests/domain/repositories/request_repository.dart';

class SuggestCategoryUseCase
    implements UseCase<CategorySuggestionEntity, SuggestCategoryParams> {
  final RequestRepository repository;
  const SuggestCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, CategorySuggestionEntity>> call(
    SuggestCategoryParams params,
  ) {
    final description = params.description.trim();
    if (description.length < AppConstants.minDescriptionLength) {
      return Future.value(
        Left(
          ValidationFailure(
            'Descreva com ao menos '
            '${AppConstants.minDescriptionLength} caracteres para usar a IA.',
          ),
        ),
      );
    }
    return repository.suggestCategory(description);
  }
}

class SuggestCategoryParams extends Equatable {
  final String description;
  const SuggestCategoryParams(this.description);

  @override
  List<Object?> get props => [description];
}
