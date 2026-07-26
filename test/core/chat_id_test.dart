import 'package:flutter_test/flutter_test.dart';
import 'package:test_chat_application/core/utils/chat_id.dart';

void main() {
  group('buildChatId', () {
    test('sorts user ids deterministically', () {
      expect(buildChatId('userB', 'userA'), 'userA_userB');
      expect(buildChatId('userA', 'userB'), 'userA_userB');
    });

    test('returns same id when called with swapped arguments', () {
      const a = 'abc';
      const b = 'xyz';
      expect(buildChatId(a, b), buildChatId(b, a));
    });
  });
}
