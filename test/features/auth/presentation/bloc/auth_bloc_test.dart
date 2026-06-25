import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_requests/core/error/failures.dart';
import 'package:tracking_requests/core/usecases/usecase.dart';
import 'package:tracking_requests/features/auth/domain/entities/session_entity.dart';
import 'package:tracking_requests/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:tracking_requests/features/auth/domain/usecases/login_usecase.dart';
import 'package:tracking_requests/features/auth/domain/usecases/logout_usecase.dart';

import 'package:tracking_requests/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tracking_requests/features/auth/presentation/bloc/auth_event.dart';
import 'package:tracking_requests/features/auth/presentation/bloc/auth_state.dart';

class MockLogin extends Mock implements LoginUseCase {}

class MockLogout extends Mock implements LogoutUseCase {}

class MockCheckAuthStatus extends Mock implements CheckAuthStatusUseCase {}

void main() {
  late MockLogin login;
  late MockLogout logout;
  late MockCheckAuthStatus checkAuthStatus;

  // Arrange
  const tSession = SessionEntity(
    token: 't',
    userId: '1',
    userName: 'U',
    email: 'e@x.com',
  );

  setUpAll(() {
    registerFallbackValue(const LoginParams(email: '', password: ''));
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    login = MockLogin();
    logout = MockLogout();
    checkAuthStatus = MockCheckAuthStatus();
  });

  AuthBloc build() =>
      AuthBloc(login: login, logout: logout, checkAuthStatus: checkAuthStatus);

  blocTest<AuthBloc, AuthState>(
    'emits [loading, authenticated] on a successful login',
    setUp: () =>
        when(() => login(any())).thenAnswer((_) async => const Right(tSession)),

    build: build,
    act: (b) =>
        b.add(const AuthLoginRequested(email: 'e@x.com', password: 'p')),

    expect: () => const [
      AuthState(status: AuthStatus.loading),
      AuthState(status: AuthStatus.authenticated, session: tSession),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [loading, failure] when login fails',
    setUp: () => when(
      () => login(any()),
    ).thenAnswer((_) async => const Left(AuthFailure('inválido'))),

    build: build,
    act: (b) =>
        b.add(const AuthLoginRequested(email: 'e@x.com', password: 'x')),

    expect: () => const [
      AuthState(status: AuthStatus.loading),
      AuthState(status: AuthStatus.failure, errorMessage: 'inválido'),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits authenticated when a session is stored',
    setUp: () => when(
      () => checkAuthStatus(any()),
    ).thenAnswer((_) async => const Right(tSession)),

    build: build,
    act: (b) => b.add(const AuthCheckRequested()),

    expect: () => const [
      AuthState(status: AuthStatus.authenticated, session: tSession),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits unauthenticated on logout',
    setUp: () =>
        when(() => logout(any())).thenAnswer((_) async => const Right(unit)),

    build: build,
    act: (b) => b.add(const AuthLogoutRequested()),

    expect: () => const [AuthState(status: AuthStatus.unauthenticated)],
  );
}
