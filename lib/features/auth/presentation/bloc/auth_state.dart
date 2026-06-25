import 'package:equatable/equatable.dart';
import 'package:tracking_requests/features/auth/domain/entities/session_entity.dart';

enum AuthStatus { unknown, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final SessionEntity? session;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.session,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, session, errorMessage];
}
