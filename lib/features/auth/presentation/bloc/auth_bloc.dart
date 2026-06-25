import 'package:bloc/bloc.dart';
import 'package:tracking_requests/core/usecases/usecase.dart';
import 'package:tracking_requests/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:tracking_requests/features/auth/domain/usecases/login_usecase.dart';
import 'package:tracking_requests/features/auth/domain/usecases/logout_usecase.dart';
import 'package:tracking_requests/features/auth/presentation/bloc/auth_event.dart';
import 'package:tracking_requests/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase login;
  final LogoutUseCase logout;
  final CheckAuthStatusUseCase checkAuthStatus;

  AuthBloc({
    required this.login,
    required this.logout,
    required this.checkAuthStatus,
  }) : super(const AuthState()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onCheck(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await checkAuthStatus(const NoParams());
    result.fold(
      (_) => emit(const AuthState(status: AuthStatus.unauthenticated)),
      (session) => emit(
        session == null
            ? const AuthState(status: AuthStatus.unauthenticated)
            : AuthState(status: AuthStatus.authenticated, session: session),
      ),
    );
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.loading));
    final result = await login(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(
        AuthState(status: AuthStatus.failure, errorMessage: failure.message),
      ),
      (session) =>
          emit(AuthState(status: AuthStatus.authenticated, session: session)),
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await logout(const NoParams());
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
