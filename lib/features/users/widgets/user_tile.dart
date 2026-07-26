import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/common_text.dart';
import '../../../domain/entities/user_list_item.dart';

class UserTile extends StatelessWidget {
  const UserTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  final UserListItem item;
  final VoidCallback onTap;

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(time.year, time.month, time.day);
    if (day == today) return DateFormat.jm().format(time);
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat.MMMd().format(time);
  }

  @override
  Widget build(BuildContext context) {
    final user = item.user;
    final preview = item.lastMessage?.isNotEmpty == true
        ? item.lastMessage!
        : 'Tap to start chatting';
    final title =
        user.displayName.isNotEmpty ? user.displayName : user.email;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.avatarPlaceholder,
              child: CommonText(
                user.initial,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    title,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  CommonText.subtitle(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            CommonText.caption(_formatTime(item.lastMessageAt)),
          ],
        ),
      ),
    );
  }
}
