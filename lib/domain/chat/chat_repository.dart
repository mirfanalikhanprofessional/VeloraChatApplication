import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  Stream<Either<Failure, List<ChatMessage>>> watchMessages({
    required String currentUserId,
    required String peerUserId,
  });

  Future<Either<Failure, ChatMessage>> sendMessage({
    required String currentUserId,
    required String peerUserId,
    required String text,
  });

  Future<Either<Failure, ChatMessage>> updateMessage({
    required String chatId,
    required String messageId,
    required String text,
  });

  Future<Either<Failure, Unit>> deleteMessage({
    required String chatId,
    required String messageId,
  });
}
