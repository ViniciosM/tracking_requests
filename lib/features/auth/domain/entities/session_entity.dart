import 'package:equatable/equatable.dart';

class SessionEntity extends Equatable {
  final String token;
  final String userId;
  final String userName;
  final String email;

  const SessionEntity({
    required this.token,
    required this.userId,
    required this.userName,
    required this.email,
  });

  @override
  List<Object?> get props => [token, userId, userName, email];
}
