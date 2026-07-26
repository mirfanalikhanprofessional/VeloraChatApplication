import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_chat_application/core/error/exceptions.dart';
import 'package:test_chat_application/core/error/failures.dart';
import 'package:test_chat_application/data/users/users_data_source.dart';
import 'package:test_chat_application/data/users/users_repository_impl.dart';
import 'package:test_chat_application/domain/entities/app_user.dart';
import 'package:test_chat_application/domain/entities/user_list_item.dart';

class MockUsersDataSource extends Mock implements UsersDataSource {}

void main() {
  late MockUsersDataSource dataSource;
  late UsersRepositoryImpl repository;

  setUp(() {
    dataSource = MockUsersDataSource();
    repository = UsersRepositoryImpl(dataSource: dataSource);
  });

  group('UsersRepositoryImpl', () {
    test('watchUsers yields Right list', () async {
      const items = [
        UserListItem(
          user: AppUser(
            uid: 'u2',
            email: 'b@c.com',
            displayName: 'Sara',
          ),
          lastMessage: 'Hi',
        ),
      ];
      when(() => dataSource.watchUsers(any()))
          .thenAnswer((_) => Stream.value(items));

      final emissions = await repository.watchUsers('u1').toList();
      expect(emissions, hasLength(1));
      expect(emissions.first.isRight(), isTrue);
      emissions.first.fold((_) => fail('expected success'), (users) {
        expect(users.first.lastMessage, 'Hi');
        expect(users.first.user.displayName, 'Sara');
      });
    });

    test('watchUsers maps ServerException to ServerFailure', () async {
      when(() => dataSource.watchUsers(any())).thenAnswer(
        (_) => Stream.error(const ServerException('Failed to load users')),
      );

      final emissions = await repository.watchUsers('u1').toList();
      expect(emissions, hasLength(1));
      expect(emissions.first.isLeft(), isTrue);
      emissions.first.fold((failure) {
        expect(failure, isA<ServerFailure>());
      }, (_) => fail('expected failure'));
    });

    test('watchUsers maps NetworkException to NetworkFailure', () async {
      when(() => dataSource.watchUsers(any())).thenAnswer(
        (_) => Stream.error(const NetworkException('No internet connection')),
      );

      final emissions = await repository.watchUsers('u1').toList();
      expect(emissions, hasLength(1));
      expect(emissions.first.isLeft(), isTrue);
      emissions.first.fold((failure) {
        expect(failure, isA<NetworkFailure>());
        expect(failure.message, 'No internet connection');
      }, (_) => fail('expected failure'));
    });

    test('watchUsers yields empty list for empty response', () async {
      when(() => dataSource.watchUsers(any()))
          .thenAnswer((_) => Stream.value(const []));

      final emissions = await repository.watchUsers('u1').toList();
      expect(emissions.first.isRight(), isTrue);
      emissions.first.fold((_) => fail('expected success'), (users) {
        expect(users, isEmpty);
      });
    });
  });
}
