import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracking_requests/features/auth/presentation/bloc/auth_event.dart';
import 'package:tracking_requests/features/auth/presentation/screens/auth_gate.screen.dart';
import '../core/design_system/design_system.dart';
import '../core/di/injection.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

class TrackingRequestsApp extends StatelessWidget {
  final BrandConfig brand;
  const TrackingRequestsApp({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
      child: MaterialApp(
        title: brand.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.fromBrand(brand),
        home: const AuthGate(),
      ),
    );
  }
}
