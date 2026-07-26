import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_chat_application/core/storage/chat_cache_storage.dart';
import 'package:test_chat_application/core/storage/user_session_storage.dart';
import 'package:test_chat_application/domain/auth/auth_use_case.dart';
import 'package:test_chat_application/domain/entities/app_user.dart';
import 'package:test_chat_application/features/auth/bloc/auth_bloc.dart';

class MockAuthUseCase extends Mock implements AuthUseCase {}

class MockUserSessionStorage extends Mock implements UserSessionStorage {}

class MockChatCacheStorage extends Mock implements ChatCacheStorage {}

void main() {
  late AuthBloc bloc;
  late MockUserSessionStorage session;
  late MockAuthUseCase authUseCase;
  late MockChatCacheStorage chatCache;

  const user = AppUser(
    uid: 'u1',
    email: 'a@b.com',
    displayName: 'Alex',
  );

  setUp(() {
    session = MockUserSessionStorage();
    authUseCase = MockAuthUseCase();
    chatCache = MockChatCacheStorage();
    when(() => session.isRememberMeEnabled()).thenAnswer((_) async => false);
    when(() => session.getRememberedEmail()).thenAnswer((_) async => null);
    when(() => session.hasSeenWelcome()).thenAnswer((_) async => false);
    when(() => session.markWelcomeSeen()).thenAnswer((_) async {});
    when(() => session.clearSession()).thenAnswer((_) async {});
    when(() => session.clearAll()).thenAnswer((_) async {});
    when(() => session.saveSession(any())).thenAnswer((_) async {});
    when(
      () => session.saveRememberMe(
        rememberMe: any(named: 'rememberMe'),
        email: any(named: 'email'),
      ),
    ).thenAnswer((_) async {});
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

  setUpAll(() {
    registerFallbackValue(user);
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
    expect(bloc.state, isA<AuthLoginFormReady>());
  });

  test('AuthPasswordVisibilityToggled updates bloc field and rebuilds form',
      () async {
    final ready = expectLater(
      bloc.stream,
      emitsThrough(isA<AuthLoginFormReady>()),
    );
    bloc.add(const AuthLoginFormStarted());
    await ready;
    expect(bloc.obscurePassword, isTrue);

    final toggled = expectLater(
      bloc.stream,
      emits(isA<AuthLoginFormReady>()),
    );
    bloc.add(const AuthPasswordVisibilityToggled());
    await toggled;

    expect(bloc.obscurePassword, isFalse);
  });

  test('logout clears remember-me so login email is not prefilled', () async {
    when(() => authUseCase.logout())
        .thenAnswer((_) async => const Right(unit));

    bloc.rememberMe = true;
    bloc.rememberedEmail = 'a@b.com';

    final done = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<AuthLoading>(),
        isA<AuthSuccess>(),
      ]),
    );
    bloc.add(const AuthLogoutRequested());
    await done;

    expect(bloc.rememberMe, isFalse);
    expect(bloc.rememberedEmail, isNull);
    verify(() => session.clearAll()).called(1);
    verify(() => chatCache.clearAll()).called(1);
  });

  test('login with remember me saves session', () async {
    when(
      () => authUseCase.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Right(user));

    bloc.rememberMe = true;
    final done = expectLater(
      bloc.stream,
      emitsInOrder([isA<AuthLoading>(), isA<AuthSuccess>()]),
    );
    bloc.add(
      const AuthLoginRequested(email: 'a@b.com', password: 'secret1'),
    );
    await done;

    verify(
      () => session.saveRememberMe(rememberMe: true, email: 'a@b.com'),
    ).called(1);
    verify(() => session.saveSession(user)).called(1);
    verifyNever(() => session.clearSession());
  });

  test('login without remember me clears session', () async {
    when(
      () => authUseCase.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Right(user));

    bloc.rememberMe = false;
    final done = expectLater(
      bloc.stream,
      emitsInOrder([isA<AuthLoading>(), isA<AuthSuccess>()]),
    );
    bloc.add(
      const AuthLoginRequested(email: 'a@b.com', password: 'secret1'),
    );
    await done;

    verify(
      () => session.saveRememberMe(rememberMe: false, email: 'a@b.com'),
    ).called(1);
    verify(() => session.clearSession()).called(1);
    verifyNever(() => session.saveSession(any()));
  });

  test('register does not persist session', () async {
    when(
      () => authUseCase.register(
        email: any(named: 'email'),
        password: any(named: 'password'),
        displayName: any(named: 'displayName'),
      ),
    ).thenAnswer((_) async => const Right(user));

    final done = expectLater(
      bloc.stream,
      emitsInOrder([isA<AuthLoading>(), isA<AuthSuccess>()]),
    );
    bloc.add(
      const AuthRegisterRequested(
        email: 'a@b.com',
        password: 'secret1',
        displayName: 'Alex',
      ),
    );
    await done;

    verify(
      () => session.saveRememberMe(rememberMe: false, email: 'a@b.com'),
    ).called(1);
    verifyNever(() => session.saveSession(any()));
  });

  test('session check signs out Firebase user when remember me is off',
      () async {
    when(() => session.isRememberMeEnabled()).thenAnswer((_) async => false);
    when(() => authUseCase.getCurrentUser())
        .thenAnswer((_) async => const Right(user));
    when(() => authUseCase.logout())
        .thenAnswer((_) async => const Right(unit));

    final done = expectLater(
      bloc.stream,
      emits(isA<AuthSessionChecked>()),
    );
    bloc.add(const AuthCheckSessionRequested());
    await done;

    expect(bloc.currentUser, isNull);
    verify(() => authUseCase.logout()).called(1);
    verify(() => session.clearSession()).called(greaterThanOrEqualTo(1));
  });

  test('session check restores cached user when remember me is on', () async {
    when(() => session.isRememberMeEnabled()).thenAnswer((_) async => true);
    when(() => session.readSession()).thenAnswer((_) async => user);

    final done = expectLater(
      bloc.stream,
      emits(isA<AuthSessionChecked>()),
    );
    bloc.add(const AuthCheckSessionRequested());
    await done;

    expect(bloc.currentUser, user);
    verifyNever(() => authUseCase.getCurrentUser());
  });

  test('markWelcomeSeen delegates to session storage', () async {
    await bloc.markWelcomeSeen();
    verify(() => session.markWelcomeSeen()).called(1);
  });
}
