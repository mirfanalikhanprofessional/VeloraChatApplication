import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/chat/chat_repository.dart';
import 'chat_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({required this.dataSource});

  final ChatDataSource dataSource;

  @override
  Stream<Either<Failure, List<ChatMessage>>> watchMessages({
    required String currentUserId,
    required String peerUserId,
  }) async* {
    try {
      await for (final messages in dataSource.watchMessages(
        currentUserId: currentUserId,
        peerUserId: peerUserId,
      )) {
        yield Right(messages);
      }
    } on ServerException catch (e) {
      yield Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      yield Left(NetworkFailure(e.message));
    } catch (_) {
      yield const Left(UnexpectedFailure('Failed to load messages'));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String currentUserId,
    required String peerUserId,
    required String text,
  }) async {
    try {
      final message = await dataSource.sendMessage(
        currentUserId: currentUserId,
        peerUserId: peerUserId,
        text: text,
      );
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> updateMessage({
    required String chatId,
    required String messageId,
    required String text,
  }) async {
    try {
      final message = await dataSource.updateMessage(
        chatId: chatId,
        messageId: messageId,
        text: text,
      );
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    try {
      await dataSource.deleteMessage(
        chatId: chatId,
        messageId: messageId,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}
