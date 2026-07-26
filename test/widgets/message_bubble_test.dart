import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_chat_application/core/constants/app_colors.dart';
import 'package:test_chat_application/domain/entities/chat_message.dart';
import 'package:test_chat_application/features/chat/widgets/message_bubble.dart';

void main() {
  final message = ChatMessage(
    id: '1',
    chatId: 'a_b',
    senderId: 'a',
    receiverId: 'b',
    text: 'Hello world',
    timestamp: DateTime.utc(2026, 1, 1, 10, 30),
  );

  testWidgets('sent message aligns right with outgoing color', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            message: message,
            isMine: true,
            onLongPress: () {},
          ),
        ),
      ),
    );

    expect(find.text('Hello world'), findsOneWidget);
    final align = tester.widget<Align>(find.byType(Align).first);
    expect(align.alignment, Alignment.centerRight);

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(MessageBubble),
        matching: find.byType(Container),
      ).first,
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.outgoingBubble);
  });

  testWidgets('received message aligns left with incoming color',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            message: message,
            isMine: false,
            onLongPress: () {},
          ),
        ),
      ),
    );

    final align = tester.widget<Align>(find.byType(Align).first);
    expect(align.alignment, Alignment.centerLeft);

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(MessageBubble),
        matching: find.byType(Container),
      ).first,
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.incomingBubble);
  });
}
