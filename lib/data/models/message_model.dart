import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chat_message.dart';

class MessageModel extends ChatMessage {
  const MessageModel({
    required super.id,
    required super.chatId,
    required super.senderId,
    required super.receiverId,
    required super.text,
    required super.timestamp,
    super.updatedAt,
  });

  factory MessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String chatId,
  }) {
    final data = doc.data() ?? <String, dynamic>{};
    final timestamp = data['timestamp'];
    final updatedAt = data['updatedAt'];

    return MessageModel(
      id: doc.id,
      chatId: chatId,
      senderId: (data['senderId'] as String?) ?? '',
      receiverId: (data['receiverId'] as String?) ?? '',
      text: (data['text'] as String?) ?? '',
      timestamp: timestamp is Timestamp
          ? timestamp.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }
}
