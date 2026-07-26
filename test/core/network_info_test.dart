import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_chat_application/core/error/exceptions.dart';
import 'package:test_chat_application/core/network/network_info.dart';

void main() {
  group('NetworkInfo', () {
    test('isConnected is true when wifi is available', () async {
      final networkInfo = NetworkInfo(
        checkConnectivity: () async => [ConnectivityResult.wifi],
      );

      expect(await networkInfo.isConnected, isTrue);
    });

    test('isConnected is false when result is none', () async {
      final networkInfo = NetworkInfo(
        checkConnectivity: () async => [ConnectivityResult.none],
      );

      expect(await networkInfo.isConnected, isFalse);
    });

    test('isConnected is false when results are empty', () async {
      final networkInfo = NetworkInfo(
        checkConnectivity: () async => const [],
      );

      expect(await networkInfo.isConnected, isFalse);
    });

    test('ensureConnected throws NetworkException when offline', () async {
      final networkInfo = NetworkInfo(
        checkConnectivity: () async => [ConnectivityResult.none],
      );

      expect(
        () => networkInfo.ensureConnected(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('ensureConnected completes when online', () async {
      final networkInfo = NetworkInfo(
        checkConnectivity: () async => [ConnectivityResult.mobile],
      );

      await expectLater(networkInfo.ensureConnected(), completes);
    });
  });
}
