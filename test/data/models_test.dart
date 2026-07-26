import 'package:flutter_test/flutter_test.dart';
import 'package:test_chat_application/data/models/message_model.dart';
import 'package:test_chat_application/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromMap maps firestore-like fields', () {
      final model = UserModel.fromMap({
        'uid': 'u1',
        'email': 'a@b.com',
        'displayName': 'Alex',
        'bio': 'Hey',
      });

      expect(model.uid, 'u1');
      expect(model.email, 'a@b.com');
      expect(model.displayName, 'Alex');
      expect(model.bio, 'Hey');
    });

    test('toMap includes core profile fields', () {
      const model = UserModel(
        uid: 'u1',
        email: 'a@b.com',
        displayName: 'Alex',
        bio: 'Hey',
      );
      final map = model.toMap();
      expect(map['uid'], 'u1');
      expect(map['email'], 'a@b.com');
      expect(map['displayName'], 'Alex');
      expect(map['bio'], 'Hey');
    });
  });

  group('MessageModel', () {
    test('toMap includes sender, receiver, text and timestamp', () {
      final model = MessageModel(
        id: 'm1',
        chatId: 'a_b',
        senderId: 'a',
        receiverId: 'b',
        text: 'Hello',
        timestamp: DateTime.utc(2026, 1, 1, 10),
      );

      final map = model.toMap();
      expect(map['senderId'], 'a');
      expect(map['receiverId'], 'b');
      expect(map['text'], 'Hello');
      expect(map.containsKey('timestamp'), isTrue);
    });
  });
}
