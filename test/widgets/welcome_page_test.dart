import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_chat_application/core/constants/app_info.dart';
import 'package:test_chat_application/core/router/app_routes.dart';
import 'package:test_chat_application/features/auth/bloc/auth_bloc.dart';
import 'package:test_chat_application/features/auth/pages/welcome_page.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc authBloc;

  setUp(() {
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(const AuthInitial());
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => authBloc.markWelcomeSeen()).thenAnswer((_) async {});
    when(authBloc.close).thenAnswer((_) async {});
  });

  Widget buildApp() {
    return MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: AppRoutes.welcome,
        routes: [
          GoRoute(
            path: AppRoutes.welcome,
            builder: (_, __) => BlocProvider<AuthBloc>.value(
              value: authBloc,
              child: const WelcomePage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.login,
            builder: (_, __) => const Scaffold(body: Text('Login')),
          ),
          GoRoute(
            path: AppRoutes.register,
            builder: (_, __) => const Scaffold(body: Text('Register')),
          ),
        ],
      ),
    );
  }

  testWidgets('WelcomePage shows branding and auth actions', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.text(AppInfo.headline), findsOneWidget);
    expect(find.text(AppInfo.tagline), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });

  testWidgets('Sign up marks welcome as seen', (tester) async {
    await tester.pumpWidget(buildApp());

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    verify(() => authBloc.markWelcomeSeen()).called(1);
    expect(find.text('Register'), findsOneWidget);
  });

  testWidgets('Log in marks welcome as seen', (tester) async {
    await tester.pumpWidget(buildApp());

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    verify(() => authBloc.markWelcomeSeen()).called(1);
    expect(find.text('Login'), findsOneWidget);
  });
}
