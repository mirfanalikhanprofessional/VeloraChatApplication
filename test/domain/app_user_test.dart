import 'package:flutter_test/flutter_test.dart';
import 'package:test_chat_application/domain/entities/app_user.dart';

void main() {
  group('AppUser.initial', () {
    test('uses first letters of first and last name', () {
      const user = AppUser(
        uid: '1',
        email: 'a@b.com',
        displayName: 'Alex Rivera',
      );
      expect(user.initial, 'AR');
    });

    test('uses first two letters of a single name', () {
      const user = AppUser(
        uid: '1',
        email: 'a@b.com',
        displayName: 'Alex',
      );
      expect(user.initial, 'AL');
    });

    test('falls back to email local-part', () {
      const user = AppUser(
        uid: '1',
        email: 'irfan@test.com',
        displayName: '',
      );
      expect(user.initial, 'IR');
    });
  });

  group('AppUser json', () {
    test('round-trips toJson / fromJson', () {
      final user = AppUser(
        uid: '1',
        email: 'a@b.com',
        displayName: 'Alex',
        bio: 'Hello',
        createdAt: DateTime.utc(2026, 1, 2),
      );

      final restored = AppUser.fromJson(user.toJson());
      expect(restored.uid, user.uid);
      expect(restored.email, user.email);
      expect(restored.displayName, user.displayName);
      expect(restored.bio, user.bio);
      expect(restored.createdAt, user.createdAt);
    });
  });
}
