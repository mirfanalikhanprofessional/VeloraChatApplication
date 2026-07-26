import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/common_text.dart';
import '../../../domain/entities/chat_message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.onLongPress,
  });

  final ChatMessage message;
  final bool isMine;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.jm().format(message.timestamp);
    final textColor = isMine ? AppColors.onPrimary : AppColors.textPrimary;
    final metaColor = isMine
        ? AppColors.onPrimary.withValues(alpha: 0.7)
        : AppColors.textSecondary;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: isMine ? onLongPress : null,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.75,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isMine ? AppColors.outgoingBubble : AppColors.incomingBubble,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMine ? 18 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 18),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              CommonText(
                message.text,
                color: textColor,
                fontSize: 15,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.isEdited) ...[
                    CommonText.caption(
                      'edited',
                      color: metaColor,
                      fontSize: 10,
                    ),
                    const SizedBox(width: 6),
                  ],
                  CommonText.caption(
                    time,
                    color: metaColor,
                    fontSize: 11,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
