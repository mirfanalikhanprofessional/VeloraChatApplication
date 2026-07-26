part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatOpened extends ChatEvent {
  const ChatOpened({
    required this.currentUserId,
    required this.peerUserId,
  });

  final String currentUserId;
  final String peerUserId;

  @override
  List<Object?> get props => [currentUserId, peerUserId];
}

class ChatSendRequested extends ChatEvent {
  const ChatSendRequested({required this.text});

  final String text;

  @override
  List<Object?> get props => [text];
}

class ChatUpdateRequested extends ChatEvent {
  const ChatUpdateRequested({
    required this.messageId,
    required this.chatId,
    required this.text,
  });

  final String messageId;
  final String chatId;
  final String text;

  @override
  List<Object?> get props => [messageId, chatId, text];
}

class ChatDeleteRequested extends ChatEvent {
  const ChatDeleteRequested({
    required this.messageId,
    required this.chatId,
  });

  final String messageId;
  final String chatId;

  @override
  List<Object?> get props => [messageId, chatId];
}
