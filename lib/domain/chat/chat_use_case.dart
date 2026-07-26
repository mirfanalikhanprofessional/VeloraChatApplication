import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/chat_message.dart';
import 'chat_repository.dart';

/// Chat module use case — single entry for all chat operations.
class ChatUseCase {
  ChatUseCase(this._repository);

  final ChatRepository _repository;

  Stream<Either<Failure, List<ChatMessage>>> watchMessages({
    required String currentUserId,
    required String peerUserId,
  }) {
    return _repository.watchMessages(
      currentUserId: currentUserId,
      peerUserId: peerUserId,
    );
  }

  Future<Either<Failure, ChatMessage>> sendMessage({
    required String currentUserId,
    required String peerUserId,
    required String text,
  }) {
    return _repository.sendMessage(
      currentUserId: currentUserId,
      peerUserId: peerUserId,
      text: text,
    );
  }

  Future<Either<Failure, ChatMessage>> updateMessage({
    required String chatId,
    required String messageId,
    required String text,
  }) {
    return _repository.updateMessage(
      chatId: chatId,
      messageId: messageId,
      text: text,
    );
  }

  Future<Either<Failure, Unit>> deleteMessage({
    required String chatId,
    required String messageId,
  }) {
    return _repository.deleteMessage(
      chatId: chatId,
      messageId: messageId,
    );
  }
}
