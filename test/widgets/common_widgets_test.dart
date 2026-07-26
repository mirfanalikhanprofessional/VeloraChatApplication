import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_chat_application/core/widgets/common_empty_view.dart';
import 'package:test_chat_application/core/widgets/common_loading.dart';
import 'package:test_chat_application/core/widgets/responsive_center.dart';

void main() {
  group('CommonLoading', () {
    testWidgets('shows a progress indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CommonLoading()),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('CommonEmptyView', () {
    testWidgets('shows empty message without retry by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommonEmptyView(message: 'No data available'),
          ),
        ),
      );

      expect(find.text('No data available'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('shows retry button and invokes callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonEmptyView(
              message: 'No internet connection',
              onRetry: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('No internet connection'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(tapped, isTrue);
    });
  });

  group('ResponsiveCenter', () {
    testWidgets('constrains child to maxWidth on wide screens', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveCenter(
              maxWidth: 420,
              child: SizedBox(width: double.infinity, height: 40, key: Key('child')),
            ),
          ),
        ),
      );

      final box = tester.renderObject<RenderBox>(find.byKey(const Key('child')));
      expect(box.size.width, lessThanOrEqualTo(420));
    });
  });
}
