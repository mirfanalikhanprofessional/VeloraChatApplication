import 'package:connectivity_plus/connectivity_plus.dart';

import '../error/exceptions.dart';

typedef ConnectivityCheck = Future<List<ConnectivityResult>> Function();

/// Device connectivity checks for network-aware data calls.
class NetworkInfo {
  NetworkInfo({ConnectivityCheck? checkConnectivity})
      : _checkConnectivity = checkConnectivity ?? _defaultCheck;

  final ConnectivityCheck _checkConnectivity;

  static Future<List<ConnectivityResult>> _defaultCheck() {
    return Connectivity().checkConnectivity();
  }

  Future<bool> get isConnected async {
    final results = await _checkConnectivity();
    if (results.isEmpty) return false;
    return results.any((result) => result != ConnectivityResult.none);
  }

  /// Throws [NetworkException] when the device is offline.
  Future<void> ensureConnected() async {
    if (!await isConnected) {
      throw const NetworkException('No internet connection');
    }
  }
}
