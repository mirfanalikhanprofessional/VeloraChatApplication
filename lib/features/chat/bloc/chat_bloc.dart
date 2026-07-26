import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/chat/chat_use_case.dart';

part 'chat_event.dart';
part 'chat_state.dart';

/// Chat module Bloc — actions only.
/// Messages are observed via [ChatUseCase.watchMessages] in the UI.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({required ChatUseCase chatUseCase})
      : _chatUseCase = chatUseCase,
        super(const ChatInitial()) {
    on<ChatOpened>(_onOpened);
    on<ChatSendRequested>(_onSend);
    on<ChatUpdateRequested>(_onUpdate);
    on<ChatDeleteRequested>(_onDelete);
  }

  final ChatUseCase _chatUseCase;

  String? currentUserId;
  String? peerUserId;
  String? errorMessage;
  bool isSending = false;

  void _onOpened(ChatOpened event, Emitter<ChatState> emit) {
    currentUserId = event.currentUserId;
    peerUserId = event.peerUserId;
    errorMessage = null;
    isSending = false;
    emit(const ChatInitial());
  }

  Future<void> _onSend(
    ChatSendRequested event,
    Emitter<ChatState> emit,
  ) async {
    final currentUserId = this.currentUserId;
    final peerUserId = this.peerUserId;
    final text = event.text.trim();
    if (currentUserId == null ||
        peerUserId == null ||
        text.isEmpty ||
        isSending) {
      return;
    }

    isSending = true;
    errorMessage = null;
    emit(const ChatActionInProgress());

    final result = await _chatUseCase.sendMessage(
      currentUserId: currentUserId,
      peerUserId: peerUserId,
      text: text,
    );

    isSending = false;
    result.fold(
      (failure) {
        errorMessage = failure.message;
        emit(const ChatActionFailure());
      },
      (_) => emit(const ChatActionSuccess()),
    );
  }

  Future<void> _onUpdate(
    ChatUpdateRequested event,
    Emitter<ChatState> emit,
  ) async {
    errorMessage = null;
    emit(const ChatActionInProgress());
    final result = await _chatUseCase.updateMessage(
      chatId: event.chatId,
      messageId: event.messageId,
      text: event.text,
    );
    result.fold(
      (failure) {
        errorMessage = failure.message;
        emit(const ChatActionFailure());
      },
      (_) => emit(const ChatActionSuccess()),
    );
  }

  Future<void> _onDelete(
    ChatDeleteRequested event,
    Emitter<ChatState> emit,
  ) async {
    errorMessage = null;
    emit(const ChatActionInProgress());
    final result = await _chatUseCase.deleteMessage(
      chatId: event.chatId,
      messageId: event.messageId,
    );
    result.fold(
      (failure) {
        errorMessage = failure.message;
        emit(const ChatActionFailure());
      },
      (_) => emit(const ChatActionSuccess()),
    );
  }
}
