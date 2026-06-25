import 'package:bloc/bloc.dart';
import 'package:tracking_requests/features/requests/domain/usecases/get_request_detail_usecase.dart';
import 'package:tracking_requests/features/requests/domain/usecases/update_request_status_usecase.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/detail/request_detail_event.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/detail/request_detail_state.dart';

class RequestDetailBloc extends Bloc<RequestDetailEvent, RequestDetailState> {
  final GetRequestDetailUseCase getRequestDetail;
  final UpdateRequestStatusUseCase updateRequestStatus;

  RequestDetailBloc({
    required this.getRequestDetail,
    required this.updateRequestStatus,
  }) : super(const RequestDetailState()) {
    on<DetailRequested>(_onRequested);
    on<DetailStatusChanged>(_onStatusChanged);
  }

  Future<void> _onRequested(
    DetailRequested event,
    Emitter<RequestDetailState> emit,
  ) async {
    emit(state.copyWith(status: DetailStatus.loading));
    final result = await getRequestDetail(
      GetRequestDetailParams(event.localId),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: DetailStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (request) => emit(
        state.copyWith(
          status: DetailStatus.loaded,
          request: request,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onStatusChanged(
    DetailStatusChanged event,
    Emitter<RequestDetailState> emit,
  ) async {
    final current = state.request;
    if (current == null) return;
    emit(state.copyWith(status: DetailStatus.updating));
    final result = await updateRequestStatus(
      UpdateRequestStatusParams(localId: current.localId, status: event.status),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: DetailStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (updated) => emit(
        state.copyWith(
          status: DetailStatus.loaded,
          request: updated,
          clearError: true,
        ),
      ),
    );
  }
}
