import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracking_requests/features/auth/presentation/bloc/auth_event.dart';
import 'package:tracking_requests/features/auth/presentation/bloc/auth_state.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/di/injection.dart';
import '../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(text: 'maria@email.com');
  final _password = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      AuthLoginRequested(email: _email.text.trim(), password: _password.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brand = getIt<BrandConfig>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state.status == AuthStatus.loading;
            final error = state.status == AuthStatus.failure
                ? state.errorMessage
                : null;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      brand.logoIcon,
                      color: scheme.onPrimary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Entrar', style: AppTypography.h1),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Acesse sua conta para continuar',
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  AppTextField(
                    label: 'E-mail',
                    hint: 'voce@email.com',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: 'Senha',
                    hint: 'Sua senha',
                    controller: _password,
                    obscure: true,
                    errorText: error,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  PrimaryButton(
                    label: 'Entrar',
                    isLoading: isLoading,
                    onPressed: () => _submit(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
