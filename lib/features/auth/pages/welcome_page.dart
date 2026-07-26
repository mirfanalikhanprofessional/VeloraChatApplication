import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_info.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/common_widgets.dart';
import '../bloc/auth_bloc.dart';

/// Get-started screen — shown only on the first app launch.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  Future<void> _continue(BuildContext context, String route) async {
    await context.read<AuthBloc>().markWelcomeSeen();
    if (!context.mounted) return;
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 420,
          child: Column(
            children: [
              const Spacer(flex: 3),
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.chat_bubble_rounded,
                  color: AppColors.onPrimary,
                  size: 52,
                ),
              ),
              const VerticalSpace(28),
              CommonText.headline(
                AppInfo.headline,
                color: AppColors.textPrimary,
                fontSize: 32,
                textAlign: TextAlign.center,
              ),
              const VerticalSpace(10),
              const CommonText.subtitle(
                AppInfo.tagline,
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 4),
              CommonButton.primary(
                label: 'Sign up',
                onPressed: () => _continue(context, AppRoutes.register),
              ),
              const VerticalSpace(12),
              CommonButton(
                label: 'Log in',
                backgroundColor: AppColors.secondaryButton,
                foregroundColor: AppColors.textPrimary,
                onPressed: () => _continue(context, AppRoutes.login),
              ),
              const VerticalSpace(24),
            ],
          ),
        ),
      ),
    );
  }
}
