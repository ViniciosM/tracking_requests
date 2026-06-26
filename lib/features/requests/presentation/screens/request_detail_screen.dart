import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/enums/sync_status_enum.dart';
import 'package:tracking_requests/features/requests/domain/entities/request_entity.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/detail/request_detail_bloc.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/detail/request_detail_event.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/detail/request_detail_state.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/di/injection.dart';

class RequestDetailScreen extends StatelessWidget {
  final String localId;
  const RequestDetailScreen({super.key, required this.localId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RequestDetailBloc>()..add(DetailRequested(localId)),
      child: _RequestDetailView(localId: localId),
    );
  }
}

class _RequestDetailView extends StatelessWidget {
  final String localId;
  const _RequestDetailView({required this.localId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da solicitação', style: AppTypography.title),
      ),
      body: BlocConsumer<RequestDetailBloc, RequestDetailState>(
        listenWhen: (prev, curr) =>
            curr.status == DetailStatus.failure && curr.request != null,
        listener: (context, state) {
          AppSnackbar.error(
            context,
            state.errorMessage ?? 'Não foi possível atualizar o status.',
          );
        },
        builder: (context, state) {
          if (state.status == DetailStatus.loading && state.request == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == DetailStatus.failure && state.request == null) {
            return ErrorStateView(
              message: state.errorMessage ?? 'Tente novamente.',
              onRetry: () => context.read<RequestDetailBloc>().add(
                DetailRequested(localId),
              ),
            );
          }
          final request = state.request;
          if (request == null) return const SizedBox.shrink();

          final updating = state.status == DetailStatus.updating;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screen),
            children: [
              Text(request.title, style: AppTypography.h2),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  StatusChip(request.status),
                  const SizedBox(width: AppSpacing.sm),
                  if (request.syncStatus != SyncStatusEnum.synced)
                    SyncBadge(request.syncStatus),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Descrição', style: AppTypography.label),
              const SizedBox(height: AppSpacing.sm),
              Text(request.description, style: AppTypography.bodyLarge),
              const SizedBox(height: AppSpacing.xl),
              _InfoCard(request: request),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: 'Alterar status',
                isLoading: updating,
                onPressed: () => _showStatusSheet(context, request.status),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showStatusSheet(BuildContext context, RequestStatusEnum current) {
    final bloc = context.read<RequestDetailBloc>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.sheetTopRadius,
      ),
      builder: (sheetContext) => _StatusSheet(
        current: current,
        onConfirm: (status) {
          Navigator.of(sheetContext).pop();
          if (status != current) {
            bloc.add(DetailStatusChanged(status));
          }
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final RequestEntity request;
  const _InfoCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.category_outlined,
            label: 'Categoria',
            value: request.category.label,
          ),
          _InfoRow(
            icon: Icons.flag_outlined,
            label: 'Prioridade',
            value: request.priority.label,
          ),
          _InfoRow(
            icon: Icons.event_outlined,
            label: 'Criada em',
            value: _fmt(request.createdAt),
          ),
          _InfoRow(
            icon: Icons.update_outlined,
            label: 'Atualizada em',
            value: _fmt(request.updatedAt),
            isLast: true,
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: AppSpacing.md),
          Text(label, style: AppTypography.body),
          const Spacer(),
          Text(
            value,
            style: AppTypography.label.copyWith(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusSheet extends StatefulWidget {
  final RequestStatusEnum current;
  final ValueChanged<RequestStatusEnum> onConfirm;

  const _StatusSheet({required this.current, required this.onConfirm});

  @override
  State<_StatusSheet> createState() => _StatusSheetState();
}

class _StatusSheetState extends State<_StatusSheet> {
  late RequestStatusEnum _selected = widget.current;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text('Alterar status', style: AppTypography.h2),
            const SizedBox(height: AppSpacing.lg),
            ...RequestStatusEnum.values.map((status) {
              final selected = status == _selected;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: InkWell(
                  borderRadius: AppRadius.inputRadius,
                  onTap: () => setState(() => _selected = status),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.inputRadius,
                      border: Border.all(
                        color: selected ? primary : AppColors.border,
                        width: selected ? 1.5 : 1,
                      ),
                      color: selected
                          ? primary.withAlpha(38)
                          : AppColors.surface,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: selected ? primary : AppColors.textTertiary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(status.label, style: AppTypography.bodyLarge),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Confirmar',
              onPressed: () => widget.onConfirm(_selected),
            ),
          ],
        ),
      ),
    );
  }
}
