import 'dart:async';

/// Yields [source] events, applying [timeout] only to the **first** event.
///
/// Later silence (e.g. idle Firestore listeners) does not trigger a timeout.
Stream<T> withFirstEventTimeout<T>(
  Stream<T> source, {
  Duration timeout = const Duration(seconds: 20),
  Object Function()? onTimeout,
}) async* {
  final iterator = StreamIterator<T>(source);
  try {
    final hasFirst = await iterator.moveNext().timeout(
      timeout,
      onTimeout: () => throw (onTimeout?.call() ??
          TimeoutException('Timed out waiting for data', timeout)),
    );
    if (!hasFirst) return;
    yield iterator.current;
    while (await iterator.moveNext()) {
      yield iterator.current;
    }
  } finally {
    await iterator.cancel();
  }
}
