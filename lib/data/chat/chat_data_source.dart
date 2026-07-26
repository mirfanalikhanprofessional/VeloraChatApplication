import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/error/exceptions.dart';
import '../../core/network/network_info.dart';
import '../../core/storage/chat_cache_storage.dart';
import '../../core/utils/chat_id.dart';
import '../../core/utils/stream_timeout.dart';
import '../../domain/entities/chat_message.dart';
import '../models/message_model.dart';

abstract class ChatDataSource {
  Stream<List<MessageModel>> watchMessages({
    required String currentUserId,
    required String peerUserId,
  });

  Future<MessageModel> sendMessage({
    required String currentUserId,
    required String peerUserId,
    required String text,
  });

  Future<MessageModel> updateMessage({
    required String chatId,
    required String messageId,
    required String text,
  });

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  });
}

class ChatDataSourceImpl implements ChatDataSource {
  ChatDataSourceImpl({
    required FirebaseFirestore firestore,
    required ChatCacheStorage cache,
    required NetworkInfo networkInfo,
  })  : _firestore = firestore,
        _cache = cache,
        _networkInfo = networkInfo;

  final FirebaseFirestore _firestore;
  final ChatCacheStorage _cache;
  final NetworkInfo _networkInfo;

  CollectionReference<Map<String, dynamic>> _messages(String chatId) =>
      _firestore.collection('chats').doc(chatId).collection('messages');

  MessageModel _toModel(ChatMessage message) {
    return MessageModel(
      id: message.id,
      chatId: message.chatId,
      senderId: message.senderId,
      receiverId: message.receiverId,
      text: message.text,
      timestamp: message.timestamp,
      updatedAt: message.updatedAt,
    );
  }

  @override
  Stream<List<MessageModel>> watchMessages({
    required String currentUserId,
    required String peerUserId,
  }) async* {
    final chatId = buildChatId(currentUserId, peerUserId);

    final cached = _cache.readMessages(chatId);
    if (cached != null && cached.isNotEmpty) {
      yield cached.map(_toModel).toList(growable: false);
    }

    try {
      await _networkInfo.ensureConnected();

      final remote = withFirstEventTimeout(
        _messages(chatId).orderBy('timestamp', descending: false).snapshots(),
        timeout: const Duration(seconds: 20),
        onTimeout: () => const NetworkException(
          'Request timed out. Please try again.',
        ),
      );

      await for (final snapshot in remote) {
        final messages = snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc, chatId: chatId))
            .toList();
        await _cache.saveMessages(chatId, messages);
        yield messages;
      }
    } on NetworkException {
      if (cached == null || cached.isEmpty) rethrow;
    } catch (_) {
      if (cached == null || cached.isEmpty) {
        throw const ServerException('Failed to load messages');
      }
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required String currentUserId,
    required String peerUserId,
    required String text,
  }) async {
    await _networkInfo.ensureConnected();

    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw const ServerException('Message cannot be empty');
    }

    final chatId = buildChatId(currentUserId, peerUserId);
    final chatRef = _firestore.collection('chats').doc(chatId);
    final messageRef = _messages(chatId).doc();
    final now = DateTime.now();

    final model = MessageModel(
      id: messageRef.id,
      chatId: chatId,
      senderId: currentUserId,
      receiverId: peerUserId,
      text: trimmed,
      timestamp: now,
    );

    try {
      await _firestore.runTransaction((transaction) async {
        transaction.set(messageRef, {
          ...model.toMap(),
          'timestamp': FieldValue.serverTimestamp(),
        });
        transaction.set(
          chatRef,
          {
            'participants': [currentUserId, peerUserId]..sort(),
            'lastMessage': trimmed,
            'lastMessageAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }).timeout(const Duration(seconds: 15));

      return model;
    } on NetworkException {
      rethrow;
    } catch (_) {
      throw const ServerException('Failed to send message');
    }
  }

  @override
  Future<MessageModel> updateMessage({
    required String chatId,
    required String messageId,
    required String text,
  }) async {
    await _networkInfo.ensureConnected();

    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw const ServerException('Message cannot be empty');
    }

    final messageRef = _messages(chatId).doc(messageId);
    final chatRef = _firestore.collection('chats').doc(chatId);

    try {
      await messageRef.update({
        'text': trimmed,
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 15));

      final latestQuery = await _messages(chatId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));
      if (latestQuery.docs.isNotEmpty &&
          latestQuery.docs.first.id == messageId) {
        await chatRef.set(
          {
            'lastMessage': trimmed,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      final refreshed =
          await messageRef.get().timeout(const Duration(seconds: 10));
      if (!refreshed.exists) {
        throw const ServerException('Message not found');
      }
      return MessageModel.fromFirestore(refreshed, chatId: chatId);
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (_) {
      throw const ServerException('Failed to update message');
    }
  }

  @override
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    await _networkInfo.ensureConnected();

    final messageRef = _messages(chatId).doc(messageId);
    final chatRef = _firestore.collection('chats').doc(chatId);

    try {
      await messageRef.delete().timeout(const Duration(seconds: 15));

      final latestQuery = await _messages(chatId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));

      if (latestQuery.docs.isEmpty) {
        await chatRef.set(
          {
            'lastMessage': '',
            'lastMessageAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      } else {
        final latest = latestQuery.docs.first.data();
        await chatRef.set(
          {
            'lastMessage': latest['text'] ?? '',
            'lastMessageAt':
                latest['timestamp'] ?? FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
    } on NetworkException {
      rethrow;
    } catch (_) {
      throw const ServerException('Failed to delete message');
    }
  }
}
