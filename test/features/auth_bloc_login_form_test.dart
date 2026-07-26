import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_chat_application/core/storage/chat_cache_storage.dart';
import 'package:test_chat_application/core/storage/user_session_storage.dart';
import 'package:test_chat_application/domain/auth/auth_use_case.dart';
import 'package:test_chat_application/features/auth/bloc/auth_bloc.dart';

class MockAuthUseCase extends Mock implements AuthUseCase {}

class MockUserSessionStorage extends Mock implements UserSessionStorage {}

class MockChatCacheStorage extends Mock implements ChatCacheStorage {}

void main() {
  late AuthBloc bloc;
  late MockUserSessionStorage session;
  late MockAuthUseCase authUseCase;
  late MockChatCacheStorage chatCache;

  setUp(() {
    session = MockUserSessionStorage();
    authUseCase = MockAuthUseCase();
    chatCache = MockChatCacheStorage();
    when(() => session.isRememberMeEnabled()).thenAnswer((_) async => false);
    when(() => session.getRememberedEmail()).thenAnswer((_) async => null);
    when(() => session.hasSeenWelcome()).thenAnswer((_) async => false);
    when(() => session.clearAll()).thenAnswer((_) async {});
    when(() => chatCache.clearAll()).thenAnswer((_) async {});
    bloc = AuthBloc(
      authUseCase: authUseCase,
      sessionStorage: session,
      chatCache: chatCache,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  test('AuthRememberMeChanged updates bloc field and rebuilds form', () async {
    final future = expectLater(
      bloc.stream,
      emitsThrough(isA<AuthLoginFormReady>()),
    );

    bloc.add(const AuthLoginFormStarted());
    await future;
    expect(bloc.rememberMe, isFalse);

    final toggled = expectLater(
      bloc.stream,
      emits(isA<AuthLoginFormReady>()),
    );
    bloc.add(const AuthRememberMeChanged(true));
    await toggled;

    expect(bloc.rememberMe, isTrue);
  });

  test('AuthPasswordVisibilityToggled updates obscurePassword', () async {
    final ready = expectLater(
      bloc.stream,
      emitsThrough(isA<AuthLoginFormReady>()),
    );
    bloc.add(const AuthLoginFormStarted());
    await ready;

    final toggled = expectLater(
      bloc.stream,
      emits(isA<AuthLoginFormReady>()),
    );
    bloc.add(const AuthPasswordVisibilityToggled());
    await toggled;
    expect(bloc.obscurePassword, isFalse);
  });

  test('logout clears remember-me fields', () async {
    when(() => authUseCase.logout())
        .thenAnswer((_) async => const Right(unit));

    bloc.rememberMe = true;
    bloc.rememberedEmail = 'a@b.com';

    final done = expectLater(
      bloc.stream,
      emitsInOrder([isA<AuthLoading>(), isA<AuthSuccess>()]),
    );
    bloc.add(const AuthLogoutRequested());
    await done;

    expect(bloc.rememberMe, isFalse);
    expect(bloc.rememberedEmail, isNull);
    verify(() => session.clearAll()).called(1);
  });
}
