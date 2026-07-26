import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_chat_application/core/constants/app_info.dart';
import 'package:test_chat_application/features/auth/bloc/auth_bloc.dart';
import 'package:test_chat_application/features/auth/pages/welcome_page.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  testWidgets('WelcomePage shows branding and auth actions', (tester) async {
    final authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(const AuthInitial());
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => authBloc.markWelcomeSeen()).thenAnswer((_) async {});
    when(authBloc.close).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const WelcomePage(),
        ),
      ),
    );

    expect(find.text(AppInfo.headline), findsOneWidget);
    expect(find.text(AppInfo.tagline), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });
}
