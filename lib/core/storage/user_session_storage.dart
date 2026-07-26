import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/app_user.dart';

/// Persists auth session and remember-me data using [FlutterSecureStorage].
class UserSessionStorage {
  UserSessionStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _sessionKey = 'user_session';
  static const _rememberMeKey = 'remember_me';
  static const _emailKey = 'remembered_email';
  static const _welcomeSeenKey = 'welcome_seen';

  /// True after the get-started (welcome) screen has been shown once.
  Future<bool> hasSeenWelcome() async {
    return await _read(_welcomeSeenKey) == 'true';
  }

  Future<void> markWelcomeSeen() async {
    await _write(_welcomeSeenKey, 'true');
  }

  Future<bool> isRememberMeEnabled() async {
    final value = await _read(_rememberMeKey);
    return value == 'true';
  }

  Future<String?> getRememberedEmail() async {
    if (!await isRememberMeEnabled()) return null;
    return _read(_emailKey);
  }

  Future<AppUser?> readSession() async {
    if (!await isRememberMeEnabled()) {
      await clearSession();
      return null;
    }
    final raw = await _storage.read(key: _sessionKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AppUser.fromJson(map);
    } catch (_) {
      await _delete(_sessionKey);
      return null;
    }
  }

  /// Persists the signed-in user only when Remember me is enabled.
  Future<void> saveSession(AppUser user) async {
    if (!await isRememberMeEnabled()) {
      await clearSession();
      return;
    }
    await _write(_sessionKey, jsonEncode(user.toJson()));
  }

  Future<void> clearSession() async {
    await _delete(_sessionKey);
  }

  Future<void> saveRememberMe({
    required bool rememberMe,
    required String email,
  }) async {
    await _write(_rememberMeKey, rememberMe.toString());
    if (rememberMe) {
      await _write(_emailKey, email.trim());
    } else {
      await _delete(_emailKey);
      await clearSession();
    }
  }

  Future<void> clearAll() async {
    await _delete(_sessionKey);
    await _delete(_rememberMeKey);
    await _delete(_emailKey);
  }

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on MissingPluginException {
      // Native plugin not linked yet (e.g. hot restart after adding package).
    } on PlatformException {
      // Ignore encrypted-storage failures; session can still work via Firebase.
    }
  }

  Future<void> _delete(String key) async {
    try {
      await _storage.delete(key: key);
    } on MissingPluginException {
      // Ignore when plugin is unavailable.
    } on PlatformException {
      // Ignore encrypted-storage failures.
    }
  }
}
