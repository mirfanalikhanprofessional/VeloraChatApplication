import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_chat_application/core/error/exceptions.dart';
import 'package:test_chat_application/core/error/failures.dart';
import 'package:test_chat_application/data/chat/chat_data_source.dart';
import 'package:test_chat_application/data/chat/chat_repository_impl.dart';
import 'package:test_chat_application/data/models/message_model.dart';

class MockChatDataSource extends Mock implements ChatDataSource {}

void main() {
  late MockChatDataSource dataSource;
  late ChatRepositoryImpl repository;

  final message = MessageModel(
    id: 'm1',
    chatId: 'a_b',
    senderId: 'a',
    receiverId: 'b',
    text: 'Hello',
    timestamp: DateTime.utc(2026, 1, 1),
  );

  setUp(() {
    dataSource = MockChatDataSource();
    repository = ChatRepositoryImpl(dataSource: dataSource);
  });

  group('ChatRepositoryImpl', () {
    test('watchMessages yields Right list from data source', () async {
      when(
        () => dataSource.watchMessages(
          currentUserId: any(named: 'currentUserId'),
          peerUserId: any(named: 'peerUserId'),
        ),
      ).thenAnswer((_) => Stream.value([message]));

      final emissions = await repository
          .watchMessages(currentUserId: 'a', peerUserId: 'b')
          .toList();

      expect(emissions, hasLength(1));
      expect(emissions.first.isRight(), isTrue);
      emissions.first.fold((_) => fail('expected success'), (messages) {
        expect(messages, hasLength(1));
        expect(messages.first.text, 'Hello');
        expect(messages.first.senderId, 'a');
        expect(messages.first.receiverId, 'b');
      });
    });

    test('sendMessage returns Right(message)', () async {
      when(
        () => dataSource.sendMessage(
          currentUserId: any(named: 'currentUserId'),
          peerUserId: any(named: 'peerUserId'),
          text: any(named: 'text'),
        ),
      ).thenAnswer((_) async => message);

      final result = await repository.sendMessage(
        currentUserId: 'a',
        peerUserId: 'b',
        text: 'Hello',
      );

      expect(result.isRight(), isTrue);
    });

    test('sendMessage maps ServerException to ServerFailure', () async {
      when(
        () => dataSource.sendMessage(
          currentUserId: any(named: 'currentUserId'),
          peerUserId: any(named: 'peerUserId'),
          text: any(named: 'text'),
        ),
      ).thenThrow(const ServerException('Failed to send message'));

      final result = await repository.sendMessage(
        currentUserId: 'a',
        peerUserId: 'b',
        text: 'Hello',
      );

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Failed to send message');
      }, (_) => fail('expected failure'));
    });

    test('updateMessage returns updated message', () async {
      final updated = MessageModel(
        id: 'm1',
        chatId: 'a_b',
        senderId: 'a',
        receiverId: 'b',
        text: 'Updated',
        timestamp: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1, 1),
      );
      when(
        () => dataSource.updateMessage(
          chatId: any(named: 'chatId'),
          messageId: any(named: 'messageId'),
          text: any(named: 'text'),
        ),
      ).thenAnswer((_) async => updated);

      final result = await repository.updateMessage(
        chatId: 'a_b',
        messageId: 'm1',
        text: 'Updated',
      );

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected success'), (value) {
        expect(value.text, 'Updated');
        expect(value.isEdited, isTrue);
      });
    });

    test('sendMessage maps NetworkException to NetworkFailure', () async {
      when(
        () => dataSource.sendMessage(
          currentUserId: any(named: 'currentUserId'),
          peerUserId: any(named: 'peerUserId'),
          text: any(named: 'text'),
        ),
      ).thenThrow(const NetworkException('No internet connection'));

      final result = await repository.sendMessage(
        currentUserId: 'a',
        peerUserId: 'b',
        text: 'Hello',
      );

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<NetworkFailure>());
        expect(failure.message, 'No internet connection');
      }, (_) => fail('expected failure'));
    });

    test('watchMessages maps NetworkException to NetworkFailure', () async {
      when(
        () => dataSource.watchMessages(
          currentUserId: any(named: 'currentUserId'),
          peerUserId: any(named: 'peerUserId'),
        ),
      ).thenAnswer(
        (_) => Stream.error(const NetworkException('No internet connection')),
      );

      final emissions = await repository
          .watchMessages(currentUserId: 'a', peerUserId: 'b')
          .toList();

      expect(emissions, hasLength(1));
      expect(emissions.first.isLeft(), isTrue);
      emissions.first.fold((failure) {
        expect(failure, isA<NetworkFailure>());
      }, (_) => fail('expected failure'));
    });

    test('updateMessage maps NetworkException to NetworkFailure', () async {
      when(
        () => dataSource.updateMessage(
          chatId: any(named: 'chatId'),
          messageId: any(named: 'messageId'),
          text: any(named: 'text'),
        ),
      ).thenThrow(const NetworkException('No internet connection'));

      final result = await repository.updateMessage(
        chatId: 'a_b',
        messageId: 'm1',
        text: 'Updated',
      );

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<NetworkFailure>());
      }, (_) => fail('expected failure'));
    });

    test('deleteMessage maps NetworkException to NetworkFailure', () async {
      when(
        () => dataSource.deleteMessage(
          chatId: any(named: 'chatId'),
          messageId: any(named: 'messageId'),
        ),
      ).thenThrow(const NetworkException('No internet connection'));

      final result = await repository.deleteMessage(
        chatId: 'a_b',
        messageId: 'm1',
      );

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<NetworkFailure>());
      }, (_) => fail('expected failure'));
    });
  });
}
