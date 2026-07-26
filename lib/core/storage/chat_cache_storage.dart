import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/user_list_item.dart';

/// Local Hive cache for chat optimization (users list + recent messages).
/// Firestore remains the source of truth; this speeds up cold starts / offline UI.
class ChatCacheStorage {
  static const usersBoxName = 'cached_users';
  static const messagesBoxName = 'cached_messages';
  static const maxCachedMessages = 100;

  /// Cached entries older than this are treated as stale and ignored.
  static const cacheTtl = Duration(minutes: 10);

  Box<dynamic>? _usersBox;
  Box<dynamic>? _messagesBox;

  Future<void> init({String? testPath}) async {
    if (testPath != null) {
      Hive.init(testPath);
    } else {
      await Hive.initFlutter();
    }
    _usersBox = await Hive.openBox<dynamic>(usersBoxName);
    _messagesBox = await Hive.openBox<dynamic>(messagesBoxName);
  }

  Box<dynamic> get _users {
    final box = _usersBox;
    if (box == null || !box.isOpen) {
      throw StateError('ChatCacheStorage not initialized');
    }
    return box;
  }

  Box<dynamic> get _messages {
    final box = _messagesBox;
    if (box == null || !box.isOpen) {
      throw StateError('ChatCacheStorage not initialized');
    }
    return box;
  }

  List<UserListItem>? readUsers(String currentUserId) {
    final raw = _users.get(currentUserId);
    final payload = _unwrapPayload(raw);
    if (payload == null) return null;
    try {
      final items = payload['items'];
      if (items is! List) return null;
      return items
          .whereType<Map>()
          .map((item) => _userListItemFromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUsers(String currentUserId, List<UserListItem> items) async {
    final encoded = items.map(_userListItemToMap).toList(growable: false);
    await _users.put(currentUserId, _wrapPayload(encoded));
  }

  List<ChatMessage>? readMessages(String chatId) {
    final raw = _messages.get(chatId);
    final payload = _unwrapPayload(raw);
    if (payload == null) return null;
    try {
      final items = payload['items'];
      if (items is! List) return null;
      return items
          .whereType<Map>()
          .map((item) => _messageFromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveMessages(String chatId, List<ChatMessage> messages) async {
    final trimmed = messages.length > maxCachedMessages
        ? messages.sublist(messages.length - maxCachedMessages)
        : messages;
    final encoded = trimmed.map(_messageToMap).toList(growable: false);
    await _messages.put(chatId, _wrapPayload(encoded));
  }

  Future<void> clearAll() async {
    await _users.clear();
    await _messages.clear();
  }

  Map<String, dynamic> _wrapPayload(List<dynamic> items) {
    return {
      'cachedAt': DateTime.now().toIso8601String(),
      'items': items,
    };
  }

  /// Returns payload map when fresh; null when missing/stale/legacy format.
  Map<String, dynamic>? _unwrapPayload(dynamic raw) {
    if (raw == null) return null;

    // Legacy format (bare list) — force refresh.
    if (raw is List) return null;

    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final cachedAt = DateTime.tryParse(map['cachedAt'] as String? ?? '');
    if (cachedAt == null) return null;
    if (DateTime.now().difference(cachedAt) > cacheTtl) return null;
    return map;
  }

  Map<String, dynamic> _userListItemToMap(UserListItem item) {
    return {
      'user': item.user.toJson(),
      'lastMessage': item.lastMessage,
      'lastMessageAt': item.lastMessageAt?.toIso8601String(),
    };
  }

  UserListItem _userListItemFromMap(Map<String, dynamic> map) {
    final userMap = Map<String, dynamic>.from(map['user'] as Map? ?? {});
    return UserListItem(
      user: AppUser.fromJson(userMap),
      lastMessage: map['lastMessage'] as String?,
      lastMessageAt: map['lastMessageAt'] != null
          ? DateTime.tryParse(map['lastMessageAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> _messageToMap(ChatMessage message) {
    return {
      'id': message.id,
      'chatId': message.chatId,
      'senderId': message.senderId,
      'receiverId': message.receiverId,
      'text': message.text,
      'timestamp': message.timestamp.toIso8601String(),
      'updatedAt': message.updatedAt?.toIso8601String(),
    };
  }

  ChatMessage _messageFromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String? ?? '',
      chatId: map['chatId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      receiverId: map['receiverId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String)
          : null,
    );
  }
}
