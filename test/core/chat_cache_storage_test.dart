import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:test_chat_application/core/storage/chat_cache_storage.dart';
import 'package:test_chat_application/domain/entities/app_user.dart';
import 'package:test_chat_application/domain/entities/chat_message.dart';
import 'package:test_chat_application/domain/entities/user_list_item.dart';

void main() {
  late Directory tempDir;
  late ChatCacheStorage cache;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('velora_hive_');
    cache = ChatCacheStorage();
    await cache.init(testPath: tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('saves and reads users list with last message preview', () async {
    const user = AppUser(
      uid: 'u2',
      email: 'sara@test.com',
      displayName: 'Sara Malik',
    );
    final items = [
      UserListItem(
        user: user,
        lastMessage: 'Hello',
        lastMessageAt: DateTime.utc(2026, 1, 1, 12),
      ),
    ];

    await cache.saveUsers('u1', items);
    final cached = cache.readUsers('u1');

    expect(cached, isNotNull);
    expect(cached!, hasLength(1));
    expect(cached.first.user.displayName, 'Sara Malik');
    expect(cached.first.lastMessage, 'Hello');
  });

  test('saves recent messages and trims to maxCachedMessages', () async {
    final messages = List<ChatMessage>.generate(
      ChatCacheStorage.maxCachedMessages + 5,
      (index) => ChatMessage(
        id: 'm$index',
        chatId: 'a_b',
        senderId: 'a',
        receiverId: 'b',
        text: 'msg $index',
        timestamp: DateTime.utc(2026, 1, 1).add(Duration(minutes: index)),
      ),
    );

    await cache.saveMessages('a_b', messages);
    final cached = cache.readMessages('a_b');

    expect(cached, isNotNull);
    expect(cached!, hasLength(ChatCacheStorage.maxCachedMessages));
    expect(cached.first.text, 'msg 5');
    expect(cached.last.text, 'msg 104');
  });

  test('ignores stale cache past TTL', () async {
    await cache.saveUsers(
      'u1',
      const [
        UserListItem(
          user: AppUser(uid: 'u2', email: 'a@b.com', displayName: 'A'),
        ),
      ],
    );

    final box = Hive.box<dynamic>(ChatCacheStorage.usersBoxName);
    final raw = Map<String, dynamic>.from(box.get('u1') as Map);
    raw['cachedAt'] = DateTime.now()
        .subtract(ChatCacheStorage.cacheTtl + const Duration(minutes: 1))
        .toIso8601String();
    await box.put('u1', raw);

    expect(cache.readUsers('u1'), isNull);
  });

  test('ignores legacy bare-list cache format', () async {
    final box = Hive.box<dynamic>(ChatCacheStorage.usersBoxName);
    await box.put('u1', [
      {
        'user': {
          'uid': 'u2',
          'email': 'a@b.com',
          'displayName': 'A',
        },
      },
    ]);

    expect(cache.readUsers('u1'), isNull);
  });

  test('clearAll removes cached users and messages', () async {
    await cache.saveUsers(
      'u1',
      const [
        UserListItem(
          user: AppUser(
            uid: 'u2',
            email: 'a@b.com',
            displayName: 'A',
          ),
        ),
      ],
    );
    await cache.saveMessages(
      'a_b',
      [
        ChatMessage(
          id: '1',
          chatId: 'a_b',
          senderId: 'a',
          receiverId: 'b',
          text: 'hi',
          timestamp: DateTime.utc(2026, 1, 1),
        ),
      ],
    );

    await cache.clearAll();

    expect(cache.readUsers('u1'), isNull);
    expect(cache.readMessages('a_b'), isNull);
  });
}
