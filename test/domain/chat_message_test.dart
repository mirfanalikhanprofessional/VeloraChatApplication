import 'package:flutter_test/flutter_test.dart';
import 'package:test_chat_application/domain/entities/chat_message.dart';

void main() {
  group('ChatMessage', () {
    test('isEdited is false when updatedAt is null', () {
      final message = ChatMessage(
        id: '1',
        chatId: 'a_b',
        senderId: 'a',
        receiverId: 'b',
        text: 'hi',
        timestamp: DateTime.utc(2026, 1, 1),
      );
      expect(message.isEdited, isFalse);
    });

    test('isEdited is true when updatedAt is after timestamp', () {
      final message = ChatMessage(
        id: '1',
        chatId: 'a_b',
        senderId: 'a',
        receiverId: 'b',
        text: 'hi edited',
        timestamp: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1, 1),
      );
      expect(message.isEdited, isTrue);
    });

    test('copyWith updates text only', () {
      final original = ChatMessage(
        id: '1',
        chatId: 'a_b',
        senderId: 'a',
        receiverId: 'b',
        text: 'hi',
        timestamp: DateTime.utc(2026, 1, 1),
      );
      final updated = original.copyWith(text: 'hello');
      expect(updated.text, 'hello');
      expect(updated.id, original.id);
      expect(updated.senderId, original.senderId);
    });
  });
}
