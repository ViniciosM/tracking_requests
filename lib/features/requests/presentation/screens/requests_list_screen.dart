import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracking_requests/core/enums/sync_status_enum.dart';
import 'package:tracking_requests/features/auth/presentation/bloc/auth_event.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/list/request_list_bloc.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/list/request_list_event.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/list/request_list_state.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../widgets/request_card.dart';
import 'create_request_screen.dart';
import 'request_detail_screen.dart';

class RequestsListScreen extends StatelessWidget {
  const RequestsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RequestsListBloc>()..add(const ListStarted()),
      child: const _RequestsListView(),
    );
  }
}

class _RequestsListView extends StatefulWidget {
  const _RequestsListView();

  @override
  State<_RequestsListView> createState() => _RequestsListViewState();
}

class _RequestsListViewState extends State<_RequestsListView> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      context.read<RequestsListBloc>().add(const ListLoadMoreRequested());
    }
  }

  Future<void> _refresh() async {
    final bloc = context.read<RequestsListBloc>();
    bloc.add(const ListRefreshed());
    await bloc.stream.firstWhere((s) => !s.isRefreshing);
  }

  void _openCreate() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const CreateRequestScreen()));

  void _openDetail(String localId) => Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => RequestDetailScreen(localId: localId)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      floatingActionButton: AppFab(icon: Icons.add, onPressed: _openCreate),
      body: BlocBuilder<RequestsListBloc, RequestsListState>(
        builder: (context, state) {
          final pending = state.items
              .where((r) => r.syncStatus != SyncStatusEnum.synced)
              .length;

          return Column(
            children: [
              if (!state.isOnline)
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.md,
                    AppSpacing.screen,
                    0,
                  ),
                  child: OfflineBanner(),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.md,
                  0,
                  AppSpacing.sm,
                ),
                child: FilterBar(
                  selected: state.filter,
                  onChanged: (s) => context.read<RequestsListBloc>().add(
                    ListFilterChanged(s),
                  ),
                ),
              ),
              if (pending > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screen,
                    vertical: AppSpacing.xs,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SyncStatusIndicator(pendingCount: pending),
                  ),
                ),
              Expanded(child: _buildBody(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, RequestsListState state) {
    if (state.status == ListStatus.loading) {
      return const RequestListSkeleton();
    }
    if (state.status == ListStatus.failure && state.items.isEmpty) {
      return ErrorStateView(
        message: state.errorMessage ?? 'Tente novamente.',
        onRetry: () =>
            context.read<RequestsListBloc>().add(const ListStarted()),
      );
    }
    if (state.items.isEmpty) {
      return EmptyState(
        icon: Icons.inbox_outlined,
        title: 'Nenhuma solicitação ainda',
        message: 'Crie sua primeira solicitação para acompanhá-la aqui.',
        actionLabel: 'Nova solicitação',
        onAction: _openCreate,
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        controller: _scroll,
        padding: const EdgeInsets.all(AppSpacing.screen),
        itemCount: state.items.length + (state.hasReachedMax ? 0 : 1),
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, i) {
          if (i >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          final request = state.items[i];
          return RequestCard(
            request: request,
            onTap: () => _openDetail(request.localId),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final brand = getIt<BrandConfig>();
    final scheme = Theme.of(context).colorScheme;
    final session = context.read<AuthBloc>().state.session;
    final initials = _initials(session?.userName ?? 'U');

    return AppBar(
      titleSpacing: AppSpacing.screen,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(brand.logoIcon, color: scheme.onPrimary, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Text('Minhas solicitações', style: AppTypography.title),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'logout') {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'logout', child: Text('Sair')),
          ],
          child: Container(
            margin: const EdgeInsets.only(right: AppSpacing.screen),
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primary.withAlpha(31),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              initials,
              style: AppTypography.label.copyWith(
                fontSize: 13,
                color: scheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}
