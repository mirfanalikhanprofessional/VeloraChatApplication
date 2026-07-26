import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/error/exceptions.dart';
import '../../core/network/network_info.dart';
import '../../core/storage/chat_cache_storage.dart';
import '../../core/utils/chat_id.dart';
import '../../core/utils/stream_timeout.dart';
import '../../domain/entities/user_list_item.dart';
import '../models/user_model.dart';

abstract class UsersDataSource {
  Stream<List<UserListItem>> watchUsers(String currentUserId);
}

class UsersDataSourceImpl implements UsersDataSource {
  UsersDataSourceImpl({
    required FirebaseFirestore firestore,
    required ChatCacheStorage cache,
    required NetworkInfo networkInfo,
  })  : _firestore = firestore,
        _cache = cache,
        _networkInfo = networkInfo;

  final FirebaseFirestore _firestore;
  final ChatCacheStorage _cache;
  final NetworkInfo _networkInfo;

  @override
  Stream<List<UserListItem>> watchUsers(String currentUserId) async* {
    final cached = _cache.readUsers(currentUserId);
    if (cached != null && cached.isNotEmpty) {
      yield cached;
    }

    try {
      await _networkInfo.ensureConnected();

      final remote = withFirstEventTimeout(
        _firestore.collection('users').snapshots(),
        timeout: const Duration(seconds: 20),
        onTimeout: () => const NetworkException(
          'Request timed out. Please try again.',
        ),
      );

      await for (final snapshot in remote) {
        final users = snapshot.docs
            .map(UserModel.fromFirestore)
            .where((user) => user.uid != currentUserId)
            .toList()
          ..sort(
            (a, b) => a.displayName.toLowerCase().compareTo(
                  b.displayName.toLowerCase(),
                ),
          );

        final items = <UserListItem>[];
        for (final user in users) {
          final chatId = buildChatId(currentUserId, user.uid);
          final chatDoc = await _firestore
              .collection('chats')
              .doc(chatId)
              .get()
              .timeout(const Duration(seconds: 10));

          String? lastMessage;
          DateTime? lastMessageAt;
          if (chatDoc.exists) {
            final data = chatDoc.data();
            lastMessage = data?['lastMessage'] as String?;
            final ts = data?['lastMessageAt'];
            if (ts is Timestamp) {
              lastMessageAt = ts.toDate();
            }
          }

          items.add(
            UserListItem(
              user: user,
              lastMessage: lastMessage,
              lastMessageAt: lastMessageAt,
            ),
          );
        }

        items.sort((a, b) {
          final aTime =
              a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime =
              b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final cmp = bTime.compareTo(aTime);
          if (cmp != 0) return cmp;
          return a.user.displayName
              .toLowerCase()
              .compareTo(b.user.displayName.toLowerCase());
        });

        await _cache.saveUsers(currentUserId, items);
        yield items;
      }
    } on NetworkException {
      if (cached == null || cached.isEmpty) rethrow;
    } on ServerException {
      rethrow;
    } catch (_) {
      if (cached == null || cached.isEmpty) {
        throw const ServerException('Failed to load users');
      }
    }
  }
}
