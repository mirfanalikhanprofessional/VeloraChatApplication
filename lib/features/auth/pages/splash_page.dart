import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_info.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/common_widgets.dart';
import '../bloc/auth_bloc.dart';

/// Startup screen: checks session, then goes to home, welcome, or login.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthBloc>().add(const AuthCheckSessionRequested());
    });
  }

  Future<void> _navigateAfterSessionCheck(BuildContext context) async {
    final authBloc = context.read<AuthBloc>();
    if (authBloc.currentUser != null) {
      context.go(AppRoutes.home);
      return;
    }

    final seenWelcome = await authBloc.hasSeenWelcome;
    if (!context.mounted) return;
    context.go(seenWelcome ? AppRoutes.login : AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is AuthSessionChecked,
      listener: (context, state) {
        if (state is! AuthSessionChecked) return;
        _navigateAfterSessionCheck(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CommonText.headline(
                AppInfo.name,
                textAlign: TextAlign.center,
              ),
              const VerticalSpace(8),
              const CommonText.subtitle(
                AppInfo.tagline,
                textAlign: TextAlign.center,
              ),
              const VerticalSpace(32),
              const CommonLoading(),
            ],
          ),
        ),
      ),
    );
  }
}
