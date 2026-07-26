import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_chat_application/core/error/exceptions.dart';
import 'package:test_chat_application/core/error/failures.dart';
import 'package:test_chat_application/data/auth/auth_data_source.dart';
import 'package:test_chat_application/data/auth/auth_repository_impl.dart';
import 'package:test_chat_application/data/models/user_model.dart';

class MockAuthDataSource extends Mock implements AuthDataSource {}

void main() {
  late MockAuthDataSource dataSource;
  late AuthRepositoryImpl repository;

  const user = UserModel(
    uid: 'u1',
    email: 'a@b.com',
    displayName: 'Alex',
  );

  setUp(() {
    dataSource = MockAuthDataSource();
    repository = AuthRepositoryImpl(dataSource: dataSource);
  });

  group('AuthRepositoryImpl', () {
    test('login returns Right(user) on success', () async {
      when(
        () => dataSource.login(email: any(named: 'email'), password: any(named: 'password')),
      ).thenAnswer((_) async => user);

      final result = await repository.login(
        email: 'a@b.com',
        password: 'secret1',
      );

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected success'), (value) {
        expect(value.uid, 'u1');
        expect(value.email, 'a@b.com');
      });
    });

    test('login maps AuthException to AuthFailure', () async {
      when(
        () => dataSource.login(email: any(named: 'email'), password: any(named: 'password')),
      ).thenThrow(const AuthException('Incorrect email or password'));

      final result = await repository.login(
        email: 'a@b.com',
        password: 'bad',
      );

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Incorrect email or password');
      }, (_) => fail('expected failure'));
    });

    test('register returns Right(user) on success', () async {
      when(
        () => dataSource.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
          displayName: any(named: 'displayName'),
        ),
      ).thenAnswer((_) async => user);

      final result = await repository.register(
        email: 'a@b.com',
        password: 'secret1',
        displayName: 'Alex',
      );

      expect(result.isRight(), isTrue);
    });

    test('logout returns Right(unit)', () async {
      when(() => dataSource.logout()).thenAnswer((_) async {});

      final result = await repository.logout();
      expect(result.isRight(), isTrue);
    });

    test('updateProfile maps ServerException to ServerFailure', () async {
      when(
        () => dataSource.updateProfile(
          displayName: any(named: 'displayName'),
          bio: any(named: 'bio'),
        ),
      ).thenThrow(const ServerException('Failed to update profile'));

      final result = await repository.updateProfile(displayName: 'Alex');
      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
      }, (_) => fail('expected failure'));
    });

    test('login maps NetworkException to NetworkFailure', () async {
      when(
        () => dataSource.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const NetworkException('No internet connection'));

      final result = await repository.login(
        email: 'a@b.com',
        password: 'secret1',
      );

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<NetworkFailure>());
        expect(failure.message, 'No internet connection');
      }, (_) => fail('expected failure'));
    });

    test('register maps NetworkException to NetworkFailure', () async {
      when(
        () => dataSource.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
          displayName: any(named: 'displayName'),
        ),
      ).thenThrow(const NetworkException('No internet connection'));

      final result = await repository.register(
        email: 'a@b.com',
        password: 'secret1',
        displayName: 'Alex',
      );

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<NetworkFailure>());
      }, (_) => fail('expected failure'));
    });

    test('sendPasswordResetEmail maps NetworkException to NetworkFailure',
        () async {
      when(
        () => dataSource.sendPasswordResetEmail(email: any(named: 'email')),
      ).thenThrow(const NetworkException('Request timed out. Please try again.'));

      final result =
          await repository.sendPasswordResetEmail(email: 'a@b.com');
      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<NetworkFailure>());
      }, (_) => fail('expected failure'));
    });
  });
}
