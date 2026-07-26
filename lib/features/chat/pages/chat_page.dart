import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/injection_container.dart';
import '../../../core/error/failures.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../domain/entities/app_user.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/chat/chat_use_case.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.currentUser,
    required this.peerUser,
  });

  final AppUser currentUser;
  final AppUser peerUser;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChatBloc>().add(
            ChatOpened(
              currentUserId: widget.currentUser.uid,
              peerUserId: widget.peerUser.uid,
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return _ChatView(
      currentUser: widget.currentUser,
      peerUser: widget.peerUser,
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView({
    required this.currentUser,
    required this.peerUser,
  });

  final AppUser currentUser;
  final AppUser peerUser;

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  late final TextEditingController _controller;
  final ScrollController _scrollController = ScrollController();
  int _streamKey = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _retry() => setState(() => _streamKey++);

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _onLongPress(ChatMessage message) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () => sheetContext.pop('edit'),
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                title: const Text('Delete'),
                onTap: () => sheetContext.pop('delete'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    // Wait until the bottom sheet is fully removed from the Overlay.
    // Showing another route immediately causes go_router Overlay assertions.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const CommonText.title('Delete message?'),
          content: const CommonText.subtitle('This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => dialogContext.pop(true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed == true && mounted) {
        context.read<ChatBloc>().add(
              ChatDeleteRequested(
                messageId: message.id,
                chatId: message.chatId,
              ),
            );
      }
      return;
    }

    if (action == 'edit') {
      final updated = await showDialog<String>(
        context: context,
        builder: (dialogContext) =>
            _EditMessageDialog(initialText: message.text),
      );
      if (updated != null && updated.trim().isNotEmpty && mounted) {
        context.read<ChatBloc>().add(
              ChatUpdateRequested(
                messageId: message.id,
                chatId: message.chatId,
                text: updated,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final peerName = widget.peerUser.displayName.isNotEmpty
        ? widget.peerUser.displayName
        : widget.peerUser.email;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.avatarPlaceholder,
              child: CommonText(
                widget.peerUser.initial,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const HorizontalSpace(12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    peerName,
                    overflow: TextOverflow.ellipsis,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                  const CommonText.caption(
                    'Online',
                    color: AppColors.online,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          final chatBloc = context.read<ChatBloc>();
          if (state is ChatActionFailure && chatBloc.errorMessage != null) {
            AppToast.error(context, chatBloc.errorMessage!);
          }
          if (state is ChatActionSuccess) {
            _controller.clear();
            _scrollToBottom();
          }
        },
        child: Column(
          children: [
            Expanded(
              child: ResponsiveCenter(
                maxWidth: AppBreakpoints.isExpanded(context) ? 720 : 600,
                padding: EdgeInsets.zero,
                child: StreamBuilder<Either<Failure, List<ChatMessage>>>(
                key: ValueKey(_streamKey),
                stream: sl<ChatUseCase>().watchMessages(
                  currentUserId: widget.currentUser.uid,
                  peerUserId: widget.peerUser.uid,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const CommonLoading();
                  }

                  if (snapshot.hasError) {
                    return CommonEmptyView(
                      message: snapshot.error.toString(),
                      onRetry: _retry,
                    );
                  }

                  final result = snapshot.data;
                  if (result == null) {
                    return const CommonLoading();
                  }

                  return result.fold(
                    (failure) => CommonEmptyView(
                      message: failure.message,
                      onRetry: _retry,
                    ),
                    (messages) {
                      if (messages.isEmpty) {
                        return const CommonEmptyView(
                          message: 'No data available',
                        );
                      }

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                      });

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMine =
                              message.senderId == widget.currentUser.uid;
                          return MessageBubble(
                            message: message,
                            isMine: isMine,
                            onLongPress: () => _onLongPress(message),
                          );
                        },
                      );
                    },
                  );
                },
              ),
              ),
            ),
            BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                final isSending = context.read<ChatBloc>().isSending;
                return ResponsiveCenter(
                  maxWidth: AppBreakpoints.isExpanded(context) ? 720 : 600,
                  padding: EdgeInsets.zero,
                  child: MessageInput(
                    controller: _controller,
                    isSending: isSending || state is ChatActionInProgress,
                    onChanged: (_) {},
                    onSend: () {
                      context.read<ChatBloc>().add(
                            ChatSendRequested(text: _controller.text),
                          );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EditMessageDialog extends StatefulWidget {
  const _EditMessageDialog({required this.initialText});

  final String initialText;

  @override
  State<_EditMessageDialog> createState() => _EditMessageDialogState();
}

class _EditMessageDialogState extends State<_EditMessageDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const CommonText.title('Edit message'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Message',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => context.pop(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
