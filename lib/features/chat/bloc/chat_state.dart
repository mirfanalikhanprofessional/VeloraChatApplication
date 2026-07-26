part of 'chat_bloc.dart';

/// Status-only. Message list comes from [WatchMessages] stream in the UI.
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatActionInProgress extends ChatState {
  const ChatActionInProgress();
}

class ChatActionSuccess extends ChatState {
  const ChatActionSuccess();
}

class ChatActionFailure extends ChatState {
  const ChatActionFailure();
}
