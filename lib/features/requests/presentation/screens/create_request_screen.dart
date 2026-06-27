import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracking_requests/core/enums/request_category_enum.dart';
import 'package:tracking_requests/core/enums/request_priority_enum.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/create/create_request_bloc.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/create/create_request_event.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/create/create_request_state.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/di/injection.dart';

class CreateRequestScreen extends StatelessWidget {
  const CreateRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CreateRequestBloc>(),
      child: const _CreateRequestView(),
    );
  }
}

class _CreateRequestView extends StatefulWidget {
  const _CreateRequestView();

  @override
  State<_CreateRequestView> createState() => _CreateRequestViewState();
}

class _CreateRequestViewState extends State<_CreateRequestView> {
  final _title = TextEditingController();
  final _description = TextEditingController();

  RequestCategoryEnum? _category;
  RequestPriorityEnum _priority = RequestPriorityEnum.medium;
  bool _aiSuggested = false;

  String? _titleError;
  String? _descError;
  String? _categoryError;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  void _suggest(BuildContext context) {
    final title = _title.text.trim();
    if (title.isEmpty) {
      AppSnackbar.info(context, 'Escreva um título para gerar a descrição.');
      return;
    }
    context.read<CreateRequestBloc>().add(CreateSuggestionRequested(title));
  }

  void _submit(BuildContext context) {
    final title = _title.text.trim();
    final description = _description.text.trim();
    setState(() {
      _titleError = title.isEmpty ? 'Informe um título' : null;
      _descError = description.length < AppConstants.minDescriptionLength
          ? 'Mínimo de ${AppConstants.minDescriptionLength} caracteres'
          : null;
      _categoryError = _category == null ? 'Selecione uma categoria' : null;
    });
    if (_titleError != null || _descError != null || _categoryError != null) {
      return;
    }
    context.read<CreateRequestBloc>().add(
      CreateSubmitted(
        title: title,
        description: description,
        category: _category!,
        priority: _priority,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nova solicitação', style: AppTypography.title),
      ),
      body: BlocConsumer<CreateRequestBloc, CreateRequestState>(
        listener: (context, state) {
          if (state.suggestionStatus == SuggestionStatus.ready &&
              state.suggestedDescription != null) {
            setState(() {
              _description.text = state.suggestedDescription!;
              _descError = null;
              _aiSuggested = true;
            });
          }
          if (state.suggestionStatus == SuggestionStatus.failure) {
            AppSnackbar.error(
              context,
              state.errorMessage ?? 'Não foi possível gerar a descrição.',
            );
          }
          if (state.status == CreateStatus.success) {
            AppSnackbar.success(context, 'Solicitação criada com sucesso.');
            Navigator.of(context).pop();
          }
          if (state.status == CreateStatus.failure) {
            AppSnackbar.error(
              context,
              state.errorMessage ?? 'Não foi possível criar.',
            );
          }
        },
        builder: (context, state) {
          final submitting = state.status == CreateStatus.submitting;
          final suggesting = state.suggestionStatus == SuggestionStatus.loading;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screen),
            children: [
              AppTextField(
                label: 'Título',
                hint: 'Ex.: Agendar consulta com cardiologista',
                controller: _title,
                errorText: _titleError,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Text('Descrição', style: AppTypography.label),
                  if (_aiSuggested) ...[
                    const SizedBox(width: AppSpacing.sm),
                    const _AiHint(),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                hint: 'Descreva o que você precisa',
                controller: _description,
                maxLines: 4,
                helperText:
                    'Mín. ${AppConstants.minDescriptionLength} caracteres · ou gere com IA a partir do título',
                errorText: _descError,
                onChanged: (_) {
                  if (_aiSuggested) setState(() => _aiSuggested = false);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: AiSuggestButton(
                  isLoading: suggesting,
                  onPressed: () => _suggest(context),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Categoria', style: AppTypography.label),
              const SizedBox(height: AppSpacing.md),
              _CategoryPicker(
                selected: _category,
                onChanged: (c) => setState(() {
                  _category = c;
                  _categoryError = null;
                }),
              ),
              if (_categoryError != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _categoryError!,
                  style: AppTypography.caption.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              Text('Prioridade', style: AppTypography.label),
              const SizedBox(height: AppSpacing.md),
              _PrioritySegmented(
                selected: _priority,
                onChanged: (p) => setState(() => _priority = p),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              PrimaryButton(
                label: 'Criar solicitação',
                isLoading: submitting,
                onPressed: () => _submit(context),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AiHint extends StatelessWidget {
  const _AiHint();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: primary.withAlpha(25),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 12, color: primary),
          const SizedBox(width: 4),
          Text(
            'Sugerido por IA',
            style: AppTypography.caption.copyWith(color: primary),
          ),
        ],
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  final RequestCategoryEnum? selected;
  final ValueChanged<RequestCategoryEnum> onChanged;

  const _CategoryPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: RequestCategoryEnum.values.map((category) {
        final isSelected = category == selected;
        return InkWell(
          borderRadius: AppRadius.pillRadius,
          onTap: () => onChanged(category),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? primary : AppColors.surface,
              borderRadius: AppRadius.pillRadius,
              border: isSelected
                  ? null
                  : Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  size: 15,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  category.label,
                  style: AppTypography.label.copyWith(
                    fontSize: 13,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PrioritySegmented extends StatelessWidget {
  final RequestPriorityEnum selected;
  final ValueChanged<RequestPriorityEnum> onChanged;

  const _PrioritySegmented({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.buttonRadius,
      ),
      child: Row(
        children: RequestPriorityEnum.values.map((priority) {
          final isSelected = priority == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(priority),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isSelected ? AppShadows.card : null,
                ),
                child: Text(
                  priority.label,
                  style: AppTypography.label.copyWith(
                    fontSize: 13,
                    color: isSelected ? primary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
