import 'dart:convert';

import 'package:tracking_requests/features/auth/domain/entities/session_entity.dart';

class SessionModel extends SessionEntity {
  const SessionModel({
    required super.token,
    required super.userId,
    required super.userName,
    required super.email,
  });

  factory SessionModel.fromLoginResponse(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return SessionModel(
      token: json['token'] as String,
      userId: user['id'].toString(),
      userName: user['name'] as String,
      email: user['email'] as String,
    );
  }

  factory SessionModel.fromCache(Map<String, dynamic> json) {
    return SessionModel(
      token: json['token'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toCache() => {
    'token': token,
    'userId': userId,
    'userName': userName,
    'email': email,
  };

  String toCacheJson() => jsonEncode(toCache());

  factory SessionModel.fromCacheJson(String source) =>
      SessionModel.fromCache(jsonDecode(source) as Map<String, dynamic>);
}
