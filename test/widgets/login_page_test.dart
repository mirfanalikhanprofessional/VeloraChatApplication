import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_chat_application/features/auth/bloc/auth_bloc.dart';
import 'package:test_chat_application/features/auth/pages/login_page.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
  });

  AuthBloc mockReadyBloc({
    bool rememberMe = false,
    bool obscurePassword = true,
    String? rememberedEmail,
  }) {
    final authBloc = MockAuthBloc();
    final state = AuthLoginFormReady();
    when(() => authBloc.state).thenReturn(state);
    when(() => authBloc.stream).thenAnswer((_) => Stream.value(state));
    when(() => authBloc.isLoading).thenReturn(false);
    when(() => authBloc.rememberMe).thenReturn(rememberMe);
    when(() => authBloc.obscurePassword).thenReturn(obscurePassword);
    when(() => authBloc.rememberedEmail).thenReturn(rememberedEmail);
    when(() => authBloc.add(any())).thenReturn(null);
    when(authBloc.close).thenAnswer((_) async {});
    return authBloc;
  }

  testWidgets('LoginPage shows sign-in controls', (tester) async {
    final authBloc = mockReadyBloc();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const LoginPage(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Remember me'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
  });

  testWidgets('LoginPage dispatches AuthRememberMeChanged when checkbox tapped',
      (tester) async {
    final authBloc = mockReadyBloc();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const LoginPage(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    verify(
      () => authBloc.add(any(that: isA<AuthRememberMeChanged>())),
    ).called(1);
  });

  testWidgets('LoginPage dispatches AuthLoginRequested on Log in',
      (tester) async {
    final authBloc = mockReadyBloc(
      rememberMe: true,
      rememberedEmail: 'a@b.com',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const LoginPage(),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret1');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pump();

    verify(
      () => authBloc.add(
        any(
          that: isA<AuthLoginRequested>()
              .having((e) => e.email, 'email', 'a@b.com')
              .having((e) => e.password, 'password', 'secret1'),
        ),
      ),
    ).called(1);
  });
}
