import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracking_requests/features/auth/presentation/bloc/auth_state.dart';
import 'package:tracking_requests/features/requests/presentation/screens/requests_list_screen.dart';
import '../bloc/auth_bloc.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.authenticated:
            return const RequestsListScreen();
          case AuthStatus.unknown:
            return const SplashScreen();
          case AuthStatus.loading:
          case AuthStatus.unauthenticated:
          case AuthStatus.failure:
            return const LoginScreen();
        }
      },
    );
  }
}
