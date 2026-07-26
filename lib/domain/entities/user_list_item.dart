import 'package:equatable/equatable.dart';

import 'app_user.dart';

/// A registered user plus optional last-message preview for the users list.
class UserListItem extends Equatable {
  const UserListItem({
    required this.user,
    this.lastMessage,
    this.lastMessageAt,
  });

  final AppUser user;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  @override
  List<Object?> get props => [user, lastMessage, lastMessageAt];
}
