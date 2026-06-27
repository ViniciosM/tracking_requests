import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/request_repository.dart';
import '../entities/description_suggestion_entity.dart';

const int _minTitleLength = 5;

class SuggestDescriptionUseCase
    implements UseCase<DescriptionSuggestionEntity, SuggestDescriptionParams> {
  final RequestRepository repository;
  const SuggestDescriptionUseCase(this.repository);

  @override
  Future<Either<Failure, DescriptionSuggestionEntity>> call(
    SuggestDescriptionParams params,
  ) {
    final title = params.title.trim();
    if (title.length < _minTitleLength) {
      return Future.value(
        Left(
          ValidationFailure(
            'Escreva um título com ao menos '
            '$_minTitleLength caracteres para usar a IA.',
          ),
        ),
      );
    }
    return repository.suggestDescription(title);
  }
}

class SuggestDescriptionParams extends Equatable {
  final String title;
  const SuggestDescriptionParams(this.title);

  @override
  List<Object?> get props => [title];
}
