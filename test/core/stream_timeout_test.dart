import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:test_chat_application/core/utils/stream_timeout.dart';

void main() {
  test('withFirstEventTimeout yields events after first arrives', () async {
    final values = withFirstEventTimeout(
      Stream.fromIterable([1, 2, 3]),
      timeout: const Duration(seconds: 1),
    );

    expect(await values.toList(), [1, 2, 3]);
  });

  test('withFirstEventTimeout times out when first event is late', () async {
    final controller = StreamController<int>();
    addTearDown(controller.close);

    final values = withFirstEventTimeout(
      controller.stream,
      timeout: const Duration(milliseconds: 50),
      onTimeout: () => TimeoutException('late'),
    );

    await expectLater(values.toList(), throwsA(isA<TimeoutException>()));
  });
}
