import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/app_user.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/pages/forgot_password_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/profile_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/auth/pages/reset_password_page.dart';
import '../../features/auth/pages/splash_page.dart';
import '../../features/auth/pages/welcome_page.dart';
import '../../features/chat/pages/chat_page.dart';
import '../../features/users/pages/users_page.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      builder: (context, state) {
        final email = state.extra is String ? state.extra! as String : '';
        return ResetPasswordPage(email: email);
      },
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) {
        final user = context.read<AuthBloc>().currentUser;
        if (user == null) {
          return const LoginPage();
        }
        return UsersPage(currentUser: user);
      },
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) {
        final user = context.read<AuthBloc>().currentUser;
        if (user == null) {
          return const LoginPage();
        }
        return ProfilePage(user: user);
      },
    ),
    GoRoute(
      path: AppRoutes.chat,
      builder: (context, state) {
        final currentUser = context.read<AuthBloc>().currentUser;
        final peer = state.extra;
        if (currentUser == null || peer is! AppUser) {
          return const LoginPage();
        }
        return ChatPage(
          currentUser: currentUser,
          peerUser: peer,
        );
      },
    ),
  ],
);
